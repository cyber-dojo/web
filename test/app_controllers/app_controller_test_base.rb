require_relative '../../test/all'
require_relative '../../config/environment'
require_relative 'params_maker'
require 'json'

class AppControllerTestBase < ActionDispatch::IntegrationTest

  include TestDomainHelpers
  include TestExternalHelpers
  include TestHexIdHelpers

  # - - - - - - - - - - - - - - - -

  def in_kata(choice, &block)
    display_name = {
       stateless: 'Ruby, MiniTest',
        stateful: 'Ruby, RSpec'
    }[choice] || choice
    refute_nil display_name, choice
    create_language_kata(display_name)
    begin
      block.call
    ensure
      runner.kata_old(kata.image_name, kata.id)
    end
  end

  # - - - - - - - - - - - - - - - -

  def as_avatar(&block)
    assert_join
    begin
      block.call
    ensure
      runner.avatar_old(kata.image_name, kata.id, avatar.name)
    end
  end

  # - - - - - - - - - - - - - - - -

  def kata
    katas[@id]
  end

  def avatar
    kata.avatars[@avatar_name]
  end

  # - - - - - - - - - - - - - - - -

  def create_language_kata(display_name = default_display_name,
                           exercise_name = default_exercise_name)
    params = {
      'language' => display_name,
      'exercise' => exercise_name
    }
    get '/setup_default_start_point/save_group', params:params
    assert_response :redirect
    #http://.../kata/group/BC8E8A6433
    regex = /^(.*)\/kata\/group\/([0-9A-Za-z]*)$/
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
    params = { 'id' => kata.id, 'avatar' => avatar.name }
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
    id = options['id'] || kata.id
    manifest = kata.manifest
    params = {
      'format'           => 'js',
      'id'               => id,
      'runner_choice'    => manifest.runner_choice,
      'hidden_filenames' => JSON.unparse(manifest.hidden_filenames),
      'max_seconds'      => (options['max_seconds'] || manifest.max_seconds),
      'image_name'       => (options['image_name' ] || manifest.image_name),
      'avatar'           => avatar.name
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

