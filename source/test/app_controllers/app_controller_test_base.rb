require_relative '../../test/all'
require_relative '../../config/environment'
require 'json'

class AppControllerTestBase < ActionDispatch::IntegrationTest

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
    manifest = starter_manifest
    manifest['version'] = (options[:version] || 2)
    @id = saver.kata_create(manifest)
    @manifest = manifest
    nil
  end

  def kata
    Kata.new(self, @id)
  end

  def post_json(path, params)
    params['format'] = 'js'
    if params.key?(:data)
      params[:data] = Rack::Utils.build_nested_query(params[:data])
    end
    post path, params: params
    events = saver.kata_events(@id)
    @index = events[-1]['index'] + 1
  end

  def post_run_tests(options = {})
    params = run_test_params(options)
    post_json '/kata/run_tests', params
    assert_response :success, response.body
  end

  def run_test_params(options = {})
    {
      'id'           => (options['id'] || kata.id),
      'image_name'   => kata.manifest['image_name'],
      'max_seconds'  => (options['max_seconds'] || kata.manifest['max_seconds']),
      'index'        => (options['index'] || @index),
      'file_content' => @files,
      'predicted'    => (options['predicted'] || 'none')
    }
  end

  def json
    ActiveSupport::JSON.decode(html)
  end

  def html
    @response.body
  end

end
