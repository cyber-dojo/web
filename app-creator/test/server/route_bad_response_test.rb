require_relative 'creator_test_base'
require 'ostruct'

class RouteBadResponseTest < CreatorTestBase

  # - - - - - - - - - - - - - - - - -

  qtest f28QN4: %w[
    |when an http-proxy
    |returns non-JSON in its response.body
    |it logs the exeption to stdout
  ] do
    stub_saver_http('xxxx', '500')
    logs_exception_to_stdout(mounted_path('ready?'))
  end

  # - - - - - - - - - - - - - - - - -

  qtest f28QN6: %w[
    |when an http-proxy
    |returns JSON-Hash in its response.body
    |which contains the key "exception"
    |it logs the exception to stdout
  ] do
    response = '{"exception":42}'
    stub_saver_http(response, '500')
    logs_exception_to_stdout(mounted_path('ready?'))
  end

  # - - - - - - - - - - - - - - - - -

  qtest f28QN7: %w[
    |when an http-proxy
    |returns JSON-Hash in its response.body
    |which does not contain the requested method's key
    |it logs the exception to stdout
  ] do
    stub_saver_http('{"wibble":42}', '500')
    logs_exception_to_stdout(mounted_path('ready?'))
  end

  # - - - - - - - - - - - - - - - - -

  qtest f28QN5: %w[
    |when an http-proxy
    |returns JSON in its response.body
    |which is not a Hash
    |it logs the exception to stdout
  ] do
    stub_saver_http('[1,2,3]', '500')
    logs_exception_to_stdout(mounted_path('ready?'))
  end

  # - - - - - - - - - - - - - - - - -

  qtest f28QN8: %w[
    |when an http-proxy
    |has a 500 error
    |you get the error.erb page
    |and the exception is logged to stdout
  ] do
    not_json = 'xxxx'
    stub_exercises_start_points(not_json, '500')

    stdout, stderr = capture_io do
      get mounted_path('choose_problem'), { type: 'group' }.to_json
    end
    assert status?(500), status
    assert html_content?, content_type
    assert last_response.body.include?('<div id="error-page">')
    assert_equal '', stderr
    json = JSON.parse(stdout)
    ex = json['exception']
    assert_equal mounted_path('choose_problem'), ex['request']['path'], stdout
    assert_nil ex['request']['body'], stdout
    refute_nil ex['backtrace'], stdout
  end

  # - - - - - - - - - - - - - - - - -

  qtest f28QN9: %w[
    |when an http-proxy
    |has a 500 error
    |and the original exception is not HttpJsonHash::ServiceError
    |the exception message is logged to stdout
  ] do
    http = HttpRaiserStub.new
    esp = ExternalExercisesStartPoints.new(http)
    externals.instance_exec { @exercises_start_points = esp }
    stdout, _stderr = capture_io do
      get mounted_path('choose_problem'), { type: 'group' }.to_json
    end
    json = JSON.parse(stdout)
    ex = json['exception']
    assert_equal '42', ex['message']
  end

  private

  def stub_exercises_start_points(body, code)
    externals.instance_exec { @exercises_http = HttpAdapterStub.new(body, code) }
  end

  def stub_saver_http(body, code)
    externals.instance_exec { @saver_http = HttpAdapterStub.new(body, code) }
  end

  class HttpRaiserStub
    def get(_uri)
      raise '42'
    end
  end

  class HttpAdapterStub
    def initialize(body, code)
      @body = body
      @code = code
    end

    def get(_uri)
      OpenStruct.new
    end

    def start(_hostname, _port, _req)
      self
    end
    attr_reader :body, :code
  end

  def logs_exception_to_stdout(path)
    stdout, stderr = capture_io { get path }
    assert status?(500), status
    assert json_content?, content_type
    assert_equal '', stderr
    json = JSON.parse(stdout)
    assert_equal ['exception'], json.keys.sort, stdout
  end
end
