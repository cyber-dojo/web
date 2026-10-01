require_relative 'external_dashboard'
require_relative 'external_http'
require_relative 'external_saver'

class Externals
  def dashboard
    @dashboard ||= ExternalDashboard.new(dashboard_http)
  end

  def dashboard_http
    @dashboard_http ||= ExternalHttp.new
  end

  def saver
    @saver ||= ExternalSaver.new(saver_http)
  end

  def saver_http
    @saver_http ||= ExternalHttp.new
  end
end
