
# Setting this environment-variable means exceptions
# are _not_ routed to views/error and so can be tested.
ENV['RAILS_ENV'] = 'test'

require_relative '../../test/all'
require_relative '../../config/environment'
require_relative 'params_maker'

class AppControllerTestBase < ActionDispatch::IntegrationTest

  include TestDomainHelpers
  include TestExternalHelpers
  include TestHexIdHelpers

  # - - - - - - - - - - - - - - - -

  def in_kata(runner_choice, &block)
    display_name = {
       stateless: 'Python, unittest',
        stateful: 'C (gcc), assert',
      processful: 'Python, py.test'
    }[runner_choice]
    refute_nil display_name, runner_choice
    create_language_kata(display_name)
    begin
      block.call
    ensure
      runner.kata_old(kata.image_name, kata.id)
    end
  end

  # - - - - - - - - - - - - - - - -

  def as_avatar(&block)
    start
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

  def create_language_kata(major_minor_name = default_language_name,
                           exercise_name = default_exercise_name)
    parts = commad(major_minor_name)
    params = {
         'major' => parts[0],
         'minor' => parts[1],
      'exercise' => exercise_name
    }
    get '/setup_default_start_point/save', params:params
    @id = json['id']
  end

  # - - - - - - - - - - - - - - - -

  def create_custom_kata(major_minor_name)
    parts = commad(major_minor_name)
    params = {
         'major' => parts[0],
         'minor' => parts[1]
    }
    get '/setup_custom_start_point/save', params:params
    @id = json['id']
    nil
  end

  # - - - - - - - - - - - - - - - -

  def start
    params = { 'format' => 'json', 'id' => @id }
    get '/enter/start', params:params
    assert_response :success
    @avatar_name = json['avatar_name']
    assert_not_nil @avatar_name
    @params_maker = ParamsMaker.new(avatar)
    nil
  end

  def start_full
    params = { 'format' => 'json', 'id' => kata.id }
    get '/enter/start', params:params
    assert_response :success
  end

  def resume
    params = { 'format' => 'json', 'id' => kata.id }
    get '/enter/resume', params:params
    assert_response :success
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
    params = {
      'format'        => 'js',
      'id'            => kata.id,
      'runner_choice' => kata.runner_choice,
      'max_seconds'   => (options['max_seconds'] || kata.max_seconds),
      'image_name'    => kata.image_name,
      'avatar'        => avatar.name
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

  private # = = = = = = = = = = = =

  def commad(name)
    name.split(',').map(&:strip)
  end

end

