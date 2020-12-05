require_relative '../all'

class AppServicesTestBase < TestBase

  def set_http(klass)
    @http = klass
  end

end
