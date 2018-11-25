require_relative '../../test/all'
require_relative '../../config/environment'
require_relative 'params_maker'
require 'json'

class AppControllerTestBase < ActionDispatch::IntegrationTest

  include TestDomainHelpers
  include TestExternalHelpers
  include TestHexIdHelpers

  # - - - - - - - - - - - - - - - -

  def in_kata(&block)
    display_name = 'Ruby, MiniTest'
    create_language_kata(display_name)
    block.call(kata)
  end

  # - - - - - - - - - - - - - - - -

=begin
  def as_avatar(&block)
    assert_join
    block.call
  end
=end
  # - - - - - - - - - - - - - - - -

  def kata
    katas[@id]
  end

  #def avatar
  #  kata.avatars[@avatar_name]
  #end

  # - - - - - - - - - - - - - - - -

  def create_language_kata(display_name = default_display_name,
                           exercise_name = default_exercise_name)
    params = {
      'language' => display_name,
      'exercise' => exercise_name
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
    params = { 'display_name' => display_name }
    get '/setup_custom_start_point/save_group', params:params
    assert_response :redirect
    #http://.../kata/group/BC8E8A6433
    regex = /^(.*)\/kata\/group\/([0-9A-Za-z]*)$/
    assert m = regex.match(@response.redirect_url)
    @id = m[2]
    nil
  end

  # - - - - - - - - - - - - - - - -

  def assert_join(id = kata.id)
    @avatar_name = join(id)
    assert json['exists']
    refute_nil @avatar_name
    @params_maker = ParamsMaker.new(katas[id].avatars[@avatar_name])
    @avatar_name
  end

  def join(id)
    params = { 'format' => 'json', 'id' => id }
    get '/id_join/drop_down', params:params
    assert_response :success
    json['avatarName']
  end

  # - - - - - - - - - - - - - - - -

  def kata_edit
    params = { 'id' => kata.id }
    get '/kata/edit', params:params
    assert_response :success
  end

  def sub_file(filename, from, to)
    @params_maker.sub_file(filename, from, to)
  end

  def change_file(filename, content)
    @params_maker.change_file(filename, content)
  end

  def delete_file(filename)
    @params_maker.delete_file(filename)
  end

  def new_file(filename, content)
    @params_maker.new_file(filename, content)
  end

  def run_tests(options = {})
    params = {
      'format'           => 'js',
      'image_name'       => (options['image_name' ] || kata.manifest.image_name),
      'id'               => (options['id']          || kata.id),
      'max_seconds'      => (options['max_seconds'] || kata.manifest.max_seconds),
      'hidden_filenames' => JSON.unparse(kata.manifest.hidden_filenames),
    }
    post '/kata/run_tests', params:params.merge(@params_maker.params)
    assert_response :success
    @params_maker = ParamsMaker.new(avatar)
  end

  # - - - - - - - - - - - - - - - -

  def json
    ActiveSupport::JSON.decode html
  end

  def html
    @response.body
  end

end
