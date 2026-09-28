require_relative 'http_json_hash/service'

class ExternalSaver
  def initialize(http)
    hostname = ENV.fetch('CYBER_DOJO_SAVER_HOSTNAME', nil)
    hostname = 'saver' if hostname.nil?
    port = ENV.fetch('CYBER_DOJO_SAVER_PORT', nil)
    port = 4537 if port.nil?
    @http = HttpJsonHash.service(self.class.name, http, hostname, port)
  end

  def dir_exists_command(dirname)
    ['dir_exists?', dirname]
  end

  def file_read_command(filename)
    ['file_read', filename]
  end

  def run(command)
    @http.post(__method__, { command: command })
  end
end
