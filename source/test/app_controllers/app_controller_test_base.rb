require_relative '../all'
require_relative '../../app/app'
require 'rack/test'
require 'json'

class AppControllerTestBase < TestBase

  include Rack::Test::Methods

  def app
    Rack::Builder.new do
      use Rack::Session::Cookie,
        key: '_cyber_dojo_session',
        secret: 'test_secret_key_that_is_long_enough_to_meet_racks_minimum_requirement!'
      run App
    end
  end

  include TestDomainHelpers
  include TestExternalHelpers
  include TestHexIdHelpers

  def in_kata(options={}, &block)
    create_language_kata(options)
    @files = plain(kata.event(-1)['files'])
    @index = 1
    block.call(kata)
  end

  def create_language_kata(options = {})
    @manifest = starter_manifest
    @manifest['version'] = (options[:version] || 2)
    @id = saver.kata_create(@manifest)
    nil
  end

  def kata
    Kata.new(self, @id)
  end

  def post_json(path, params)
    if params.key?(:data)
      params[:data] = Rack::Utils.build_nested_query(params[:data])
    end
    post path, params
    events = saver.kata_events(@id)
    @index = events[-1]['index'] + 1
  end

  def post_run_tests(options = {})
    params = run_test_params(options)
    post_json '/kata/run_tests/' + (options[:id] || kata.id), params
    assert last_response.ok?, last_response.body
  end

  def run_test_params(options = {})
    {
      index:        (options[:index]       || @index),
      image_name:   @manifest['image_name'],
      max_seconds:  (options[:max_seconds] || @manifest['max_seconds']),
      file_content: @files,
      predicted:    (options[:predicted]   || 'none')
    }
  end

  def json
    JSON.parse(last_response.body)
  end

  def html
    last_response.body
  end

end
