require_relative 'http_json_hash/service_error'

module CreatorApp
  class IdTyper
    def initialize(externals)
      @externals = externals
    end

    # The first link of the saver's id_chain is the given id's own entry, so
    # its type identifies the id. The saver names a kata 'kata'; we expose it
    # as 'single'. An unknown id makes id_chain a 400 (RequestError); that is
    # our nil.
    def id_type(id)
      type = saver.id_chain(id).first['type']
      type == 'kata' ? 'single' : type
    rescue HttpJsonHash::ServiceError => e
      raise unless e.status.to_i == 400

      nil
    end

    private

    def saver
      @externals.saver
    end
  end
end
