require 'sinatra/base'
require 'digest'
require 'json'
require 'rack/protection'
require_relative 'services/externals'
require_relative '../lib/files_from'
require_relative 'models/kata'
require_relative 'models/runner'

class App < Sinatra::Base

  set :views, "#{__dir__}/views"
  set :public_folder, File.expand_path('../public', __dir__)
  set :host_authorization, {}
  set :protection, except: [:http_origin, :json_csrf]
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
    # laptop_id identifies a browser profile, not a tab: it is a cookie, so all
    # tabs in one browser share it. This is deliberate. Mobbing detection treats a
    # different laptop_id as a different laptop, so opening a second tab on the
    # same kata just to read the instructions (a common case) must not look like a
    # second laptop. Sharing one laptop_id means the active tab's committed events
    # carry the reader tab's own id, so the read-side poll's otherLaptopPresent
    # predicate ignores them and shows no "mobbing?" dialog. A separate browser
    # profile or private window gets its own laptop_id and is correctly treated as
    # another laptop.
    @laptop_id = request.cookies['laptop_id']
    unless @laptop_id
      @laptop_id = SecureRandom.hex(32)
      response.set_cookie('laptop_id', value: @laptop_id, path: '/')
    end
    unless %w[GET HEAD OPTIONS TRACE].include?(request.request_method)
      token = request.env['HTTP_X_CSRF_TOKEN'] || params['authenticity_token']
      halt 403, 'Forbidden' unless token == @csrf_token
    end
  end

  # Compiled assets live in ${APP_DIR}/assets, a sibling of source/, populated
  # by the Dockerfile from the asset_builder stage. This mirrors ../creator and
  # ../dashboard and keeps the precompiled app.css/app.js out of the repo tree.
  ASSETS_DIR = "#{ENV.fetch('APP_DIR')}/assets"

  def self.asset_path(filename)
    src = "#{ASSETS_DIR}/#{filename}"
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
    cache_control :public, max_age: 31536000, immutable: true
    content_type 'text/css'
    send_file "#{ASSETS_DIR}/app.css"
  end

  get JS_PATH do
    cache_control :public, max_age: 31536000, immutable: true
    content_type 'text/javascript'
    send_file "#{ASSETS_DIR}/app.js"
  end

  # - - - - - - - - - - - - - - - -
  # Probes

  get '/alive/?' do
    content_type :json
    { 'alive?' => true }.to_json
  end

  get '/ready/?' do
    content_type :json
    { 'ready?' => true }.to_json
  end

  # - - - - - - - - - - - - - - - -
  # Review

  get '/review/show/:id' do
    @runtime_env = ENV
    @id = params[:id]
    @manifest = saver.kata_manifest(@id)
    @title = "review:#{@id}"
    erb :'review/show'
  end

  # - - - - - - - - - - - - - - - -
  # Kata

  get '/kata/edit/:id' do
    @runtime_env = ENV
    @id = @title = params[:id]
    @manifest = saver.kata_manifest(@id)
    @events = saver.kata_events(@id)
    last = saver.kata_event(@id, -1)
    @files = last['files']
    @stdout = last['stdout'] || { 'content' => '', 'truncated' => false }
    @stderr = last['stderr'] || { 'content' => '', 'truncated' => false }
    @status = last['status'] || ''
    erb :'kata/edit'
  end

  # - - - - - - - - - - - - - - - -
  # Inter-test file events

  post '/kata/file_create' do
    content_type :json
    saver.kata_file_create(id, params_files, params[:filename], laptop_id).to_json
  end

  post '/kata/file_delete' do
    content_type :json
    saver.kata_file_delete(id, params_files, params[:filename], laptop_id).to_json
  end

  post '/kata/file_rename' do
    content_type :json
    saver.kata_file_rename(id, params_files, params[:old_filename], params[:new_filename], laptop_id).to_json
  end

  post '/kata/file_edit' do
    content_type :json
    saver.kata_file_edit(id, params_files, laptop_id).to_json
  end

  # - - - - - - - - - - - - - - - -
  # The core run-tests

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
      ran_tests(@id, @files, @stdout, @stderr, @status, {
        duration: @duration,
        colour: @outcome,
        predicted: params['predicted'],
        revert_if_wrong: params['revert_if_wrong']
      })
      @saved = true
    rescue SaverService::Error => error
      # The saver write failed (it is down or unreachable), but the runner
      # already produced this traffic-light so we still show it. The browser
      # owns the displayed number and resolves a light's committed index lazily
      # from its major_index, so this uncommitted "ghost" carries no index.
      @saved = false
      $stdout.puts(error.message)
      $stdout.flush
    end

    @light = {
      'colour'      => @outcome,
      'duration'    => @duration,
      'predicted'   => params['predicted'],
      'revert_if_wrong' => params['revert_if_wrong']
    }

    content_type :json
    {
      light:       @light,
      outcome:     @outcome,
      stdout:      @stdout['content'],
      stderr:      @stderr['content'],
      status:      @status.to_s,
      log:         @log.to_s,
      saved:       @saved == true,
      created:     @created,
      changed:     @changed
    }.to_json
  end

  # - - - - - - - - - - - - - - - -
  # Auto-revert (edit page) back to the previous traffic-light after a
  # predicted-wrong [test]. Reverting to a past light chosen on the review page
  # goes through /kata/checkout instead.

  post '/kata/auto_revert' do
    content_type :json
    events = saver.kata_events(id)
    # The auto-revert always reverts from the head (the just-tested light), so seed
    # the scan at the event before the head - read from the committed events, not
    # the client index - then walk back to the previous light.
    previous_index = events.size - 2
    while !light?(events[previous_index])
      previous_index -= 1
    end
    args = [id, previous_index]
    json = source_event(id, previous_index, :revert, args)
    # The browser owns the displayed number and resolves the reverted light's
    # committed index lazily from its major_index, so the response carries no
    # position - just the source_event's files/outcome and revert metadata.
    saver.kata_reverted(id, @files, @stdout, @stderr, @status, {
      colour: @colour,
      revert: args
    }, laptop_id)
    json.to_json
  end

  # - - - - - - - - - - - - - - - -
  # Checkout traffic-light from other avatar in group

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
    # The browser owns the displayed number and resolves the checkout light's
    # committed index lazily from its major_index, so the response carries no
    # position - just the source_event's files/outcome and checkout metadata.
    saver.kata_checked_out(id, @files, @stdout, @stderr, @status, summary, laptop_id)
    json.to_json
  end

  # - - - - - - - - - - - - - - - -
  # Set light/dark or colour-syntax option

  post '/kata/option_set' do
    content_type :json
    saver.kata_option_set(id, params[:name], params[:value])
    {}.to_json
  end

  # - - - - - - - - - - - - - - - -
  # Fork

  post '/kata/fork' do
    content_type :json
    { 'kata_fork' => saver.kata_fork(id, index) }.to_json
  end

  post '/group/fork' do
    content_type :json
    { 'group_fork' => saver.group_fork(id, index) }.to_json
  end

  # - - - - - - - - - - - - - - - -
  # Diff

  get '/kata/diff_summary' do
    content_type :json
    { diff_summary: saver.diff_summary(params[:id], params[:was_index].to_i, params[:now_index].to_i) }.to_json
  end

  get '/kata/diff_lines' do
    content_type :json
    { diff_lines: saver.diff_lines(params[:id], params[:was_index].to_i, params[:now_index].to_i) }.to_json
  end

  # - - - - - - - - - - - - - - - -
  # The next event index the browser should hold. Lets a browser that lost
  # the response to an inter-test file event (eg its fetch aborted while the
  # saver still committed the event) resync its index to the committed head,
  # instead of sending a stale index the saver would reject as an out-of-order
  # event and the browser would show as a false mobbing dialog.

  get '/kata/next_index/:id' do
    content_type :json
    events = saver.kata_events(params[:id])
    { next_index: events.last['index'] + 1 }.to_json
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

  # The id forwarded to saver on each event-write so it can stamp the writer
  # (mobbing detection). The browser sends its per-tab tab_id with the write; the
  # stored id is the laptop half (first 32 of the cookie) plus that tab_id, so the
  # read-side poll can tell one tab from another. A write without a tab_id (an old
  # or non-JS client) falls back to the plain cookie.
  def laptop_id
    tab_id = params['tab_id']
    tab_id ? @laptop_id[0, 32] + tab_id : @laptop_id
  end

  def params_files
    data = Rack::Utils.parse_nested_query(params[:data])
    files_from(data['file_content'])
  end

  def ran_tests(id, files, stdout, stderr, status, summary)
    if summary[:predicted] === 'none'
      saver.kata_ran_tests(id, files, stdout, stderr, status, summary, laptop_id)
    elsif summary[:predicted] === summary[:colour]
      saver.kata_predicted_right(id, files, stdout, stderr, status, summary, laptop_id)
    else
      saver.kata_predicted_wrong(id, files, stdout, stderr, status, summary, laptop_id)
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
       light: { colour: @colour, name => value }
    }
  end

  # A light is any event that is NOT a file event - the same exclusion-list
  # predicate saver uses (poly_filler.rb is_light?), so the two cannot silently
  # drift if a new light colour is added. The create event (colour nil) and every
  # traffic-light colour are lights; only the four file events are not.
  FILE_EVENTS = %w( file_create file_delete file_rename file_edit )

  def light?(event)
    !FILE_EVENTS.include?(event['colour'])
  end

end
