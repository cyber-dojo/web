# frozen_string_literal: true

require_relative 'http_json/service'
require_relative 'http_json/error'

class SaverService

  class Error < HttpJson::Error
    def initialize(message)
      super
    end
  end

  def initialize(externals)
    @http = HttpJson::service(externals.http, 'saver', 4537, Error)
  end

  def ready?
    @http.get(__method__, {})
  end

  def alive?
    @http.get(__method__, {})
  end

  def sha
    @http.get(__method__, {})
  end

  def create(key)
    @http.post(__method__, { key:key })
  end

  def exists?(key)
    @http.get(__method__, { key:key })
  end

  def write(key, value)
    @http.post(__method__, { key:key, value:value })
  end

  def append(key, value)
    @http.post(__method__, { key:key, value:value })
  end

  def read(key)
    @http.get(__method__, { key:key })
  end

  def batch(commands)
    @http.post(__method__, { commands:commands })
  end

end
