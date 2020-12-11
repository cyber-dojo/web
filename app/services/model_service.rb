# frozen_string_literal: true
require_relative 'http_json/requester'
require_relative 'http_json/responder'

class ModelService

  class Error < RuntimeError
    def initialize(message)
      super
    end
  end

  def initialize(externals)
    hostname = 'model'
    port = ENV['CYBER_DOJO_MODEL_PORT'].to_i
    requester = HttpJson::Requester.new(externals.http, hostname, port)
    @http = HttpJson::Responder.new(requester, Error)
  end

  def ready?
    @http.get(__method__, {})
  end

  # - - - - - - - - - - - - - - - - - -

  def group_create(manifest)
    @http.post(__method__, {manifests:[manifest], options:{}})
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
    @http.post(__method__, {manifest:manifest, options:{}})
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
      id:id,
      index:index,
      files:files,
      stdout:stdout,
      stderr:stderr,
      status:status,
      summary:summary
    })
  end

  def kata_option_get(id, name)
    @http.get(__method__, {id:id, name:name})
  end

  def kata_option_set(id, name, value)
    @http.post(__method__, {id:id, name:name, value:value})    
  end

end
