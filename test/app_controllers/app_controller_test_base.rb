require_relative '../../test/all'
require_relative '../../config/environment'
require 'json'

class AppControllerTestBase < ActionDispatch::IntegrationTest

  include TestDomainHelpers
  include TestExternalHelpers
  include TestHexIdHelpers

  # - - - - - - - - - - - - - - - -

  def starter_manifest
    em = exercises.manifest(default_exercise_name)
    manifest = languages.manifest(default_display_name)
    manifest['visible_files'].merge!(em['visible_files'])
    manifest['exercise'] = default_exercise_name
    manifest['created'] = time.now
    manifest
  end

  # - - - - - - - - - - - - - - - -

  def in_kata(&block)
    display_name = 'Ruby, MiniTest'
    create_language_kata(display_name)
    @files = kata.files.map{|filename,file| [filename,file['content']]}.to_h
    @index = 0
    block.call(kata)
  end

  def kata
    katas[@id]
  end

  def create_language_kata(display_name = default_display_name,
                           exercise_name = default_exercise_name)
    params = {
      language:display_name,
      exercise:exercise_name
    }
    get '/setup_default_start_point/save_individual', params:params
    assert_response :redirect
    #http://.../kata/edit/Bc84S3
    regex = /^(.*)\/kata\/edit\/([0-9A-Za-z]*)$/
    assert m = regex.match(@response.redirect_url)
    @id = m[2]
    nil
  end

  # - - - - - - - - - - - - - - - -

  def create_custom_kata(display_name)
    params = { display_name:display_name }
    get '/setup_custom_start_point/save_group', params:params
    assert_response :redirect
    #http://.../kata/group/6433rG
    regex = /^(.*)\/kata\/group\/([0-9A-Za-z]*)$/
    assert m = regex.match(@response.redirect_url)
    @id = m[2]
    nil
  end

  # - - - - - - - - - - - - - - - -

  def sub_file(filename, from, to)
    refute_nil @files
    assert @files.keys.include?(filename), @files.keys.sort
    content = @files[filename]
    assert content.include?(from)
    @files[filename] = content.sub(from, to)
  end

  # - - - - - - - - - - - - - - - -

  def change_file(filename, content)
    refute_nil @files
    assert @files.keys.include?(filename), @files.keys.sort
    @files[filename] = content
  end

  # - - - - - - - - - - - - - - - -

  def post_run_tests(options = {})
    post '/kata/run_tests', params:run_test_params(options)
    @index += 1
    assert_response :success
  end

  # - - - - - - - - - - - - - - - -

  def run_test_params(options = {})
    {
      'format'           => 'js',
      'image_name'       => (options['image_name' ] || kata.manifest.image_name),
      'id'               => (options['id']          || kata.id),
      'max_seconds'      => (options['max_seconds'] || kata.manifest.max_seconds),
      'hidden_filenames' => JSON.unparse(kata.manifest.hidden_filenames),
      'index'            => @index,
      'file_content'     => @files
    }
  end

  # - - - - - - - - - - - - - - - -

  def assert_join(gid)
    kid = join(gid)
    assert json['exists']
    refute_nil kid
    katas[kid]
  end

  def join(gid)
    params = { id:gid }
    get '/id_join/drop_down', params:params, as: :json
    assert_response :success
    json['id']
  end

  # - - - - - - - - - - - - - - - -

  def json
    ActiveSupport::JSON.decode(html)
  end

  def html
    @response.body
  end

end
