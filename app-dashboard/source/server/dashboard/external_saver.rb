require_relative 'http_json_hash/service'

module DashboardApp
  class ExternalSaver
    def initialize(http)
      hostname = ENV.fetch('CYBER_DOJO_SAVER_HOSTNAME', 'saver')
      port = ENV.fetch('CYBER_DOJO_SAVER_PORT', 4537)
      @http = HttpJsonHash.service(self.class.name, http, hostname, port)
    end

    def ready?
      @http.get(__method__, {})
    end

    # The id-chain from the given entity up to the topmost one, ordered
    # bottom-to-top as [{type,id}, ...]; eg a kata in a cluster returns
    # [{kata},{group},{cluster}]. Lets the dashboard resolve any id (kata,
    # group or cluster) up to the topmost entity it should render.
    def id_chain(id)
      @http.get(__method__, { id: id })
    end

    # The cluster's stored manifest; its 'groups' is a map of child group_id to
    # that child's group manifest (one child per LTF).
    def cluster_manifest(id)
      @http.get(__method__, { id: id })
    end

    def group_manifest(id)
      @http.get(__method__, { id: id })
    end

    def group_joined(id)
      @http.get(__method__, { id: id })
    end

    def katas_events(ids, indexes)
      @http.get(__method__, { ids: ids, indexes: indexes })
    end

    def diff_summary(id, was_index, now_index)
      @http.get(__method__,
                { id: id, was_index: was_index, now_index: now_index })
    end
  end
end
