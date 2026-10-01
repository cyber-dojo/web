require_relative 'services_test_base'
require 'ostruct'

class HttpJsonRequesterPerRequestHttpTest < ServicesTestBase

  def hex_setup
    externals.runner_class = RunnerService
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - -

  # Test double for the HTTP class the services make their requests with.
  # Counts how many http objects get built, so a test can tell an object built
  # per request from one built once and shared by every request. Returns a
  # minimal valid JSON response (keyed by the request path) so the responder
  # does not raise.
  class HttpJsonRequesterCountingStub
    class << self
      attr_accessor :count
    end
    def initialize(_hostname, _port)
      self.class.count += 1
    end
    def request(_req)
      OpenStruct.new(body: { 'ready?' => true }.to_json)
    end
  end

  test 'K7Bc3F',
  'each request builds its own http object, so requests running concurrently in different threads share no socket state' do
    HttpJsonRequesterCountingStub.count = 0
    set_http(HttpJsonRequesterCountingStub)
    runner.ready?
    runner.ready?
    assert_equal 2, HttpJsonRequesterCountingStub.count, :http_object_built_per_request
  end

end
