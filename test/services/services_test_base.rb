require_relative '../all'
require_relative 'capture_stdout_stderr'

class ServicesTestBase < TestBase

  # Substitutes the http library the services request with. Pokes the externals,
  # which owns it - the test object used to own it, when it was the externals.
  def set_http(klass)
    externals.instance_exec(klass) { |it| @http = it }
  end

  include CaptureStdoutStderr

end
