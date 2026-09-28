require_relative 'http_json_hash/service'

module CreatorApp
  class ExternalRunner
    def initialize(http)
      service = ENV['CYBER_DOJO_RUNNER_HOSTNAME']
      service = 'runner' if service.nil?
      port = ENV['CYBER_DOJO_RUNNER_PORT'].to_i
      @http = HttpJsonHash.service(self.class.name, http, service, port)
    end

    attr_reader :http

    def ready?
      @http.get(__method__, {})
    end

    def pull_image(id, image_name)
      @http.post(__method__, { id: id, image_name: image_name })
    end
  end
end
