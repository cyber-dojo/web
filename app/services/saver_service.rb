# frozen_string_literal: true
require_relative 'http_json/requester'
require_relative 'http_json/responder'

class SaverService

  class Error < RuntimeError
    def initialize(message)
      super
    end
  end

  def initialize(externals)
    hostname = ENV['CYBER_DOJO_SAVER_HOSTNAME']
    if hostname.nil?
      hostname = 'saver'
    end    
    port = ENV['CYBER_DOJO_SAVER_PORT'].to_i
    requester = HttpJson::Requester.new(externals.http, hostname, port)
    @http = HttpJson::Responder.new(requester, Error)
  end

  def ready?
    @http.get(__method__, {})
  end

  # - - - - - - - - - - - - - - - - - -

  def group_create(manifest)
    @http.post(__method__, {manifest:manifest})
  end

  def group_exists?(id)
    @http.get(__method__, {id:id})
  end

  def group_manifest(id)
    @http.get(__method__, {id:id})
  end

  def group_join(id)
    @http.post(__method__, {id:id})
  end

  def group_joined(id)
    @http.get(__method__, {id:id})
  end

  # - - - - - - - - - - - - - - - - - -

  def kata_create(manifest)
    @http.post(__method__, {manifest:manifest})
  end

  def kata_exists?(id)
    @http.get(__method__, {id:id})
  end

  def kata_manifest(id)
    @http.get(__method__, {id:id})
  end

  def kata_events(id)
    @http.get(__method__, {id:id})
  end

  def kata_event(id, index)
    @http.get(__method__, {id:id, index:index})
  end

  def kata_ran_tests(id, index, files, stdout, stderr, status, summary)
    @http.post(__method__, {
      id:id, index:index,
      files:files, stdout:stdout, stderr:stderr, status:status,
      summary:summary
    })
  end

  def kata_predicted_right(id, index, files, stdout, stderr, status, summary)
    @http.post(__method__, {
      id:id, index:index,
      files:files, stdout:stdout, stderr:stderr, status:status,
      summary:summary
    })
  end

  def kata_predicted_wrong(id, index, files, stdout, stderr, status, summary)
    @http.post(__method__, {
      id:id, index:index,
      files:files, stdout:stdout, stderr:stderr, status:status,
      summary:summary
    })
  end

  def kata_reverted(id, index, files, stdout, stderr, status, summary)
    @http.post(__method__, {
      id:id, index:index,
      files:files, stdout:stdout, stderr:stderr, status:status,
      summary:summary
    })
  end

  def kata_checked_out(id, index, files, stdout, stderr, status, summary)
    @http.post(__method__, {
      id:id, index:index,
      files:files, stdout:stdout, stderr:stderr, status:status,
      summary:summary
    })
  end

end
