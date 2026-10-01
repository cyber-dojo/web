require_relative 'http_json_hash/service'

module CreatorApp
  class ExternalCustomStartPoints
    def initialize(http)
      name = ENV['CYBER_DOJO_CUSTOM_START_POINTS_HOSTNAME']
      name = 'custom-start-points' if name.nil?
      port = ENV['CYBER_DOJO_CUSTOM_START_POINTS_PORT'].to_i
      @http = HttpJsonHash.service(self.class.name, http, name, port)
    end

    attr_reader :http

    def ready?
      @http.get(__method__, {})
    end

    def names
      @http.get(__method__, {})
    end

    def manifests
      @http.get(__method__, {})
    end

    def manifest(name)
      @http.get(__method__, { name: name })
    end
  end
end
