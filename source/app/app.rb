require 'sinatra/base'
require 'digest'
require 'json'
require 'rack/protection'
require_relative 'services/externals'
require_relative '../lib/files_from'

Dir.glob("#{__dir__}/models/*.rb").each { |f| require f }

class App < Sinatra::Base

  set :views, "#{__dir__}/views"
  set :public_folder, File.expand_path('../public', __dir__)
  set :host_authorization, {}
  set :protection, except: :http_origin
  enable :static

  def initialize
    super
    @default_layout = :'layouts/application'
  end

  before do
    @csrf_token = request.cookies['csrf_token']
    unless @csrf_token
      @csrf_token = SecureRandom.hex(32)
      response.set_cookie('csrf_token', value: @csrf_token, path: '/')
    end
    # Phase 2: uncomment once all users have reloaded and have the csrf_token cookie
    # unless %w[GET HEAD OPTIONS TRACE].include?(request.request_method)
    #   halt 403, 'Forbidden' unless params['authenticity_token'] == @csrf_token
    # end
  end

  PUBLIC_DIR = File.expand_path('../public', __dir__)

  def self.asset_path(filename)
    src = "#{PUBLIC_DIR}/assets/#{filename}"
    hash = Digest::SHA256.file(src).hexdigest[0, 8]
    base = File.basename(filename, '.*')
    ext  = File.extname(filename)
    "/assets/#{base}-#{hash}#{ext}"
  end

  CSS_PATH = asset_path('app.css')
  JS_PATH  = asset_path('app.js')

  include Externals
  include FilesFrom

  helpers do

    def partial(name)
      parts = name.split('/')
      parts[-1] = "_#{parts[-1]}"
      erb :"#{parts.join('/')}", layout: false
    end

    def j(str)
      str.to_s
        .gsub('\\') { '\\\\' }
        .gsub("\r\n") { '\\n' }
        .gsub("\n") { '\\n' }
        .gsub("\r") { '\\n' }
        .gsub('"') { '\\"' }
        .gsub("'") { "\\'" }
    end

  end

  # - - - - - - - - - - - - - - - -
  # Assets

  get CSS_PATH do
    cache_control :public, max_age: 31536000
    content_type 'text/css'
    send_file "#{PUBLIC_DIR}/assets/app.css"
  end

  get JS_PATH do
    cache_control :public, max_age: 31536000
    content_type 'text/javascript'
    send_file "#{PUBLIC_DIR}/assets/app.js"
  end

  # - - - - - - - - - - - - - - - -
  # Rack probes

  get '/alive/?' do
    content_type :json
    { 'alive?' => true }.to_json
  end

  get '/ready/?' do
    content_type :json
    { 'ready?' => true }.to_json
  end

  get '/web/sha/?' do
    content_type :json
    { 'sha' => ENV['SHA'] }.to_json
  end

  # - - - - - - - - - - - - - - - -
  # Kata

  get '/kata/edit/:id' do
    @runtime_env = ENV
    @id = @title = params[:id]
    @events = saver.kata_events(@id)
    last = saver.kata_event(@id, -1)
    @files = last['files']
    @stdout = last['stdout'] || { 'content' => '', 'truncated' => false }
    @stderr = last['stderr'] || { 'content' => '', 'truncated' => false }
    @status = last['status'] || ''
    erb :'kata/edit'
  end

  post '/kata/run_tests/:id' do
    @id = params[:id]
    kata = Kata.new(self, @id)
    t1 = time.now
    result, @files, @created, @changed = kata.run_tests(params)
    t2 = time.now
    @duration = Time.mktime(*t2) - Time.mktime(*t1)
    @stdout = result['stdout']
    @stderr = result['stderr']
    @status = result['status']
    @log    = result['log']
    @outcome = result['outcome']

    if @files.key?('outcome.special')
      @outcome = "#{@outcome}_special"
      @created.delete('outcome.special')
      @changed.delete('outcome.special')
      @files.delete('outcome.special')
    end

    begin
      result = ran_tests(@id, index, @files, @stdout, @stderr, @status, {
        duration: @duration,
        colour: @outcome,
        predicted: params['predicted'],
        revert_if_wrong: params['revert_if_wrong']
      })
      next_index  = result['next_index']
      major_index = result['major_index']
      minor_index = result['minor_index']
    rescue SaverService::Error => error
      next_index  = index + 1
      major_index = index + 1
      minor_index = ''
      @saved = false
      $stdout.puts(error.message)
      $stdout.flush
      @out_of_sync = error.message.include?('Out of order event')
    end

    @light = {
      'index'       => next_index - 1,
      'major_index' => major_index,
      'minor_index' => minor_index,
      'colour'      => @outcome,
      'duration'    => @duration,
      'predicted'   => params['predicted'],
      'revert_if_wrong' => params['revert_if_wrong']
    }

    content_type 'application/javascript'
    erb :'kata/run_tests.js', layout: false
  end

  post '/kata/checkout' do
    content_type :json
    from = {
      id:           params[:src_id],
      index:        params[:src_index].to_i,
      major_index:  params[:src_major_index].to_i,
      minor_index:  params[:src_minor_index].to_i,
      avatarIndex:  (params[:src_avatar_index] != '') ? params[:src_avatar_index].to_i : '',
    }
    json = source_event(from[:id], from[:index], :checkout, from)
    summary = { colour: @colour, checkout: from }
    result = saver.kata_checked_out(id, index, @files, @stdout, @stderr, @status, summary)
    light = json[:light]
    light[:index]       = result['next_index'] - 1
    light[:major_index] = result['major_index']
    light[:minor_index] = result['minor_index']
    json.to_json
  end

  post '/kata/revert' do
    content_type :json
    events = saver.kata_events(id)
    previous_index = index - 2
    while !light?(events[previous_index])
      previous_index -= 1
    end
    args = [id, previous_index]
    json = source_event(id, previous_index, :revert, args)
    result = saver.kata_reverted(id, index, @files, @stdout, @stderr, @status, {
      colour: @colour,
      revert: args
    })
    light = json[:light]
    light[:index]       = result['next_index'] - 1
    light[:major_index] = result['major_index']
    light[:minor_index] = result['minor_index']
    json.to_json
  end

  post '/kata/file_create' do
    content_type :json
    saver.kata_file_create(id, index, params_files, params[:filename]).to_json
  end

  post '/kata/file_delete' do
    content_type :json
    saver.kata_file_delete(id, index, params_files, params[:filename]).to_json
  end

  post '/kata/file_rename' do
    content_type :json
    saver.kata_file_rename(id, index, params_files, params[:old_filename], params[:new_filename]).to_json
  end

  post '/kata/file_edit' do
    content_type :json
    saver.kata_file_edit(id, index, params_files).to_json
  end

  get '/kata/events' do
    content_type :json
    { 'kata_events' => saver.kata_events(id) }.to_json
  end

  get '/kata/manifest' do
    content_type :json
    { 'kata_manifest' => saver.kata_manifest(id) }.to_json
  end

  get '/kata/download' do
    content_type :json
    { 'kata_download' => saver.kata_download(id) }.to_json
  end

  get '/kata/option_get' do
    content_type :json
    { 'kata_option_get' => saver.kata_option_get(id, params[:name]) }.to_json
  end

  post '/kata/option_set' do
    content_type :json
    saver.kata_option_set(id, params[:name], params[:value])
    {}.to_json
  end

  # - - - - - - - - - - - - - - - -
  # Review

  get '/review/show/:id' do
    @runtime_env = ENV
    @id = params[:id]
    @title = "review:#{@id}"
    erb :'review/show'
  end

  # - - - - - - - - - - - - - - - -
  # Errors

  get '*' do
    status 404
    erb :'error/404', layout: :'layouts/error'
  end

  error do
    status 500
    erb :'error/500', layout: :'layouts/error'
  end

  # - - - - - - - - - - - - - - - -

  private

  def id
    params[:id]
  end

  def index
    params[:index].to_i
  end

  def params_files
    data = Rack::Utils.parse_nested_query(params[:data])
    files_from(data['file_content'])
  end

  def ran_tests(id, index, files, stdout, stderr, status, summary)
    if summary[:predicted] === 'none'
      saver.kata_ran_tests(id, index, files, stdout, stderr, status, summary)
    elsif summary[:predicted] === summary[:colour]
      saver.kata_predicted_right(id, index, files, stdout, stderr, status, summary)
    else
      saver.kata_predicted_wrong(id, index, files, stdout, stderr, status, summary)
    end
  end

  def source_event(src_id, src_index, name, value)
    event = saver.kata_event(src_id, src_index)
    @files  = event['files']
    @stdout = event['stdout']
    @stderr = event['stderr']
    @status = event['status']
    @colour = (src_index == 0) ? 'create' : event['colour']
    {
       files: @files.map { |filename, file| [filename, file['content']] }.to_h,
      stdout: @stdout,
      stderr: @stderr,
      status: @status,
       light: { colour: @colour, index: index, name => value }
    }
  end

  def light?(event)
    return true if event['index'] == 0
    case event['colour']
    when 'red', 'amber', 'green', 'red_special', 'amber_special', 'green_special'
      true
    else
      false
    end
  end

end
