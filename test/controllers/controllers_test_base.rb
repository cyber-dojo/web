require_relative '../test_base'
require_source 'apps/mounted_apps'
require 'rack/test'
require 'json'

class ControllersTestBase < TestBase

  parallelize_me!

  include Rack::Test::Methods

  def app
    # Rack::Builder instance_evals its block, so self inside is the builder, not
    # this test - hold the app in a local the block closes over.
    app_instance = Web.mounted(externals)
    Rack::Builder.new do
      use Rack::Session::Cookie,
        key: '_cyber_dojo_session',
        secret: 'test_secret_key_that_is_long_enough_to_meet_racks_minimum_requirement!'
      run app_instance
    end
  end

  include TestDomainHelpers
  include TestExternalHelpers
  include TestHexIdHelpers

  def in_kata(options={}, &block)
    create_language_kata(options)
    @files = plain(kata.event(-1)['files'])
    block.call(kata)
  end

  def create_language_kata(options = {})
    @manifest = starter_manifest
    @manifest['version'] = (options[:version] || 2)
    @id = saver.kata_create(@manifest)
    nil
  end

  def kata
    Kata.new(externals, @id)
  end

  def post(path, params = {}, env = {})
    unless rack_mock_session.cookie_jar['csrf_token']
      get '/alive'
    end
    super(path, params.merge(authenticity_token: rack_mock_session.cookie_jar['csrf_token']), env)
  end

  def post_json(path, params)
    if params.key?(:data)
      params[:data] = Rack::Utils.build_nested_query(params[:data])
    end
    post path, params
    # Writes are async: web POSTs to the spooler, whose drainer forwards to saver.
    # Wait for the caller's tab_seq to drain, so a test that then reads committed
    # state sees this write (a write that commits nothing - a bad id, the rescue
    # path - just times out).
    wait_until_committed(@id, params[:tab_seq])
  end

  def post_run_tests(options = {})
    params = run_test_params(options)
    post_json '/kata/run_tests/' + (options[:id] || kata.id), params
    assert last_response.ok?, last_response.body
    # A run_tests with a pending edit commits two events sharing one tab_seq (the
    # underneath file_edit, then the light); post_json's tab_seq wait can return on
    # the file_edit, so wait for the light itself (its outcome colour, committed
    # last) so a following read sees the whole write. A bad-id run commits nothing,
    # so this simply times out.
    wait_until_committed(@id, params[:tab_seq], colour: json.dig('light', 'colour'))
  end

  # POSTs a [test] run without waiting for a committed event, for a test whose
  # spooler write is arranged to fail: there is nothing to wait for, and
  # post_run_tests would burn both its commit timeouts before returning.
  def post_run_tests_failing_write(options = {})
    post '/kata/run_tests/' + (options[:id] || kata.id), run_test_params(options)
  end

  def run_test_params(options = {})
    {
      image_name:   @manifest['image_name'],
      max_seconds:  (options[:max_seconds] || @manifest['max_seconds']),
      file_content: @files,
      predicted:    (options[:predicted]   || 'none'),
      rag_lambda:   (options[:rag_lambda]  || @manifest['rag_lambda']),
      tab_id:       (options[:tab_id]      || tab_id),
      tab_seq:      (options[:tab_seq]     || next_tab_seq)
    }
  end

  def json
    JSON.parse(last_response.body)
  end

end
