require_relative 'test_base'
require 'json'
require 'ostruct'

class ErrorHandlerTest < TestBase

  # The saver http adapter is stubbed in both tests, so this id is never
  # resolved - it only has to be a well-formed id.
  GROUP_ID = '9aZUWE'

  # - - - - - - - - - - - - - - - - -

  test 'e5r8h1', %w(
  | when a saver call answers a body that is not JSON, the route 500s with a
  | json diagnostic naming the failed http service, and logs that same
  | diagnostic to stdout
  ) do
    externals.instance_exec { @saver_http = HttpAdapterStub.new('xxxx') }

    exception = assert_500_diagnostic['exception']
    assert_equal %w[backtrace http_service request], exception.keys.sort, exception
    assert_equal({ 'path' => mounted_path('diff_summary'), 'body' => nil },
                 exception['request'], exception)

    service = exception['http_service']
    assert_equal %w[args body message name path], service.keys.sort, service
    assert_equal 'diff_summary', service['path'], service
    assert_equal 'DashboardApp::ExternalSaver', service['name'], service
    assert_equal 'xxxx', service['body'], service
    assert_equal({ 'id' => GROUP_ID, 'was_index' => 1, 'now_index' => 2 },
                 service['args'], service)
    expected = [
      'body is not JSON',
      'diff_summary',
      'xxxx'
    ]
    assert_equal expected.join("\n"), service['message'], service
  end

  # - - - - - - - - - - - - - - - - -

  test 'e5r8h2', %w(
  | when a saver call raises something that is not a ServiceError, the route
  | 500s with a json diagnostic carrying the exception's own message instead
  | of any http-service detail
  ) do
    externals.instance_exec { @saver_http = HttpRaiserStub.new }

    exception = assert_500_diagnostic['exception']
    assert_equal %w[backtrace message request], exception.keys.sort, exception
    assert_equal '42', exception['message'], exception
  end

  # - - - - - - - - - - - - - - - - -

  test 'e5r8h3', %w(
  | when a saver call answers valid JSON that is not a Hash, the diagnostic
  | names that as the http-service failure
  ) do
    externals.instance_exec { @saver_http = HttpAdapterStub.new('42') }

    service = assert_500_diagnostic['exception']['http_service']
    assert_equal '42', service['body'], service
    expected = [
      'body is not JSON Hash',
      'diff_summary',
      '42'
    ]
    assert_equal expected.join("\n"), service['message'], service
  end

  # - - - - - - - - - - - - - - - - -

  test 'e5r8h4', %w(
  | when a saver call answers a JSON Hash that lacks the called method's own
  | key, the diagnostic names that as the http-service failure
  ) do
    body = '{"wibble":42}'
    externals.instance_exec { @saver_http = HttpAdapterStub.new(body) }

    service = assert_500_diagnostic['exception']['http_service']
    assert_equal body, service['body'], service
    expected = [
      'body is missing :path key',
      'diff_summary',
      body
    ]
    assert_equal expected.join("\n"), service['message'], service
  end

  # - - - - - - - - - - - - - - - - -

  test 'e5r8h5', %w(
  | when the failing request carries a body, the diagnostic echoes that body.
  | A bodyless request has no rack.input at all under rack 3, which is why the
  | handler reads it with safe navigation
  ) do
    externals.instance_exec { @saver_http = HttpAdapterStub.new('xxxx') }
    request_body = 'some-request-body'

    exception = assert_500_diagnostic(JSON_HEADERS.merge(input: request_body))['exception']
    assert_equal({ 'path' => mounted_path('diff_summary'), 'body' => request_body },
                 exception['request'], exception)
  end

  private

  # GETs /diff_summary, asserts a 500 json response whose body is exactly the
  # diagnostic the handler also logs to stdout, and returns it parsed.
  JSON_HEADERS = { 'HTTP_ACCEPT' => 'application/json' }.freeze

  def assert_500_diagnostic(env = JSON_HEADERS)
    stdout, stderr = capture_io do
      get mounted_path("diff_summary?id=#{GROUP_ID}&was_index=1&now_index=2"), {}, env
    end
    assert status?(500), "status=#{status}"
    assert_equal 'application/json', content_type, content_type
    assert_equal '', stderr, :stderr
    assert_equal last_response.body, stdout.chomp, :stdout
    JSON.parse(last_response.body)
  end

  # An http adapter whose every response carries the given body, so the
  # unpacker's JSON parse of it decides what happens next.
  class HttpAdapterStub
    def initialize(body)
      @body = body
    end

    def get(_uri)
      OpenStruct.new
    end

    def start(_hostname, _port, _req)
      self
    end

    attr_reader :body
  end

  # An http adapter that fails before any response exists, so the error
  # reaching the handler is not a ServiceError.
  class HttpRaiserStub
    def get(_uri)
      raise '42'
    end
  end
end
