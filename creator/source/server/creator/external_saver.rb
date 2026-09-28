require_relative 'http_json_hash/service'

module CreatorApp
  class ExternalSaver
    def initialize(http)
      service = ENV['CYBER_DOJO_SAVER_HOSTNAME']
      service = 'saver' if service.nil?
      port = ENV['CYBER_DOJO_SAVER_PORT'].to_i
      @http = HttpJsonHash.service(self.class.name, http, service, port)
    end

    attr_reader :http

    def ready?
      @http.get(__method__, {})
    end

    def id_chain(id)
      @http.get(__method__, { id: id })
    end

    def cluster_create(manifests)
      @http.post(__method__, { manifests: manifests })
    end

    def cluster_exists?(id)
      @http.get(__method__, { id: id })
    end

    def cluster_manifest(id)
      @http.get(__method__, { id: id })
    end

    # - - - - - - - - - - - - - - - - -

    def group_create(manifest)
      @http.post(__method__, { manifest: manifest })
    end

    def group_exists?(id)
      @http.get(__method__, { id: id })
    end

    def group_manifest(id)
      @http.get(__method__, { id: id })
    end

    def group_join(id, indexes = nil)
      args = { id: id }
      args[:indexes] = indexes unless indexes.nil?
      @http.post(__method__, args)
    end

    def group_joined(id)
      @http.get(__method__, { id: id })
    end

    # - - - - - - - - - - - - - - - - -

    def kata_create(manifest)
      @http.post(__method__, { manifest: manifest })
    end

    def kata_exists?(id)
      @http.get(__method__, { id: id })
    end

    def kata_manifest(id)
      @http.get(__method__, { id: id })
    end
  end
end
