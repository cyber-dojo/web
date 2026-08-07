require_relative '../all'
require_relative '../capture_stdout_stderr'

class ServicesTestBase < TestBase

  parallelize_me!

  # Substitutes the http library the services make their requests with, by
  # poking externals, which owns it.
  def set_http(klass)
    externals.instance_exec(klass) { |it| @http = it }
  end

  include CaptureStdoutStderr

end
