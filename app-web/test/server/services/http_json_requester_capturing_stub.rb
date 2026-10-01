require 'json'
require 'ostruct'

# Test double for the HTTP class SaverService uses. Captures the body of the
# last request so a test can assert what SaverService sent, and returns a
# minimal valid JSON response (keyed by the request path) so the responder
# does not raise.
class HttpJsonRequesterCapturingStub
  class << self
    attr_accessor :last_request_body
  end
  def initialize(_hostname, _port)
  end
  def request(req)
    self.class.last_request_body = req.body
    path = req.path.sub(%r{\A/}, '')
    OpenStruct.new(body: { path => {} }.to_json)
  end
end
