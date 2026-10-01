require_relative 'require_source'
require_source 'external_http'
require_source 'http_json_hash/service'

# Saver microservice
class ExternalDiffer
  def initialize
    hostname = 'differ'
    port = ENV.fetch('CYBER_DOJO_DIFFER_PORT')
    @http = DashboardApp::HttpJsonHash.service(self.class.name, DashboardApp::ExternalHttp.new, hostname, port)
  end

  def diff_lines(id, was_index, now_index)
    @http.get(__method__, { id: id, was_index: was_index, now_index: now_index })
  end

  def diff_summary(id, was_index, now_index)
    @http.get(__method__, { id: id, was_index: was_index, now_index: now_index })
  end
end
