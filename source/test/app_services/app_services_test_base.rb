require_relative '../all'
require_relative 'capture_stdout_stderr'

class AppServicesTestBase < TestBase

  def set_http(klass)
    @http = klass
  end

  include CaptureStdoutStderr

end
