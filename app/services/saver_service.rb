require_relative 'http_json/request_packer'
require_relative 'http_json/response_unpacker'
require_relative 'saver_exception'

class SaverService

  def initialize(externals)
    requester = HttpJson::RequestPacker.new(externals.http, 'saver', 4537)
    @http = HttpJson::ResponseUnpacker.new(requester, SaverException)
  end

  # - - - - - - - - - - - -

  def ready?
    @http.get(__method__, {})
  end

  def sha
    @http.get(__method__, {})
  end

  # - - - - - - - - - - - -

  def group_exists?(id)
    @http.get(__method__, { id:id })
  end

  def group_create(manifest)
    @http.post(__method__, { manifest:manifest })
  end

  def group_manifest(id)
    @http.get(__method__, { id:id })
  end

  def group_join(id, indexes)
    @http.post(__method__, {
      id:id,
      indexes:indexes
    })
  end

  def group_joined(id)
    @http.get(__method__, { id:id })
  end

  def group_events(id)
    @http.get(__method__, { id:id })
  end

  # - - - - - - - - - - - -

  def kata_exists?(id)
    @http.get(__method__, { id:id })
  end

  def kata_create(manifest)
    @http.post(__method__, { manifest:manifest })
  end

  def kata_manifest(id)
    @http.get(__method__, { id:id })
  end

  def kata_ran_tests(id, index, files, now, duration, stdout, stderr, status, colour)
    @http.post(__method__, {
      id:id,
      index:index,
      files:files,
      now:now,
      duration:duration,
      stdout:stdout,
      stderr:stderr,
      status:status,
      colour:colour
    })
  end

  def kata_events(id)
    @http.get(__method__, { id:id })
  end

  def kata_event(id, index)
    @http.get(__method__, {
      id:id,
      index:index
    })
  end

end
