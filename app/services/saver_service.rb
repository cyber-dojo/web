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
    requester = HttpJson::Requester.new(externals.http, 'saver', 4537)
    @http = HttpJson::Responder.new(requester, Error, {keyed:true})
  end

  def ready?
    @http.get(__method__, {})
  end

  # - - - - - - - - - - - - - - - - - - -

  def create_command(dirname)
    ['create',dirname]
  end

  def exists_command(dirname)
    ['exists?',dirname]
  end

  def write_command(filename, content)
    ['write',filename,content]
  end

  def append_command(filename, content)
    ['append',filename,content]
  end

  def read_command(filename)
    ['read',filename]
  end

  # - - - - - - - - - - - - - - - - - - -

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

  def assert(command)
    @http.post(__method__, { command:command })
  end

  def batch_assert(commands)
    @http.post(__method__, { commands:commands })
  end

  def batch(commands)
    @http.post(__method__, { commands:commands })
  end

  def batch_until_true(commands)
    @http.post(__method__, { commands:commands })
  end

  def batch_until_false(commands)
    @http.post(__method__, { commands:commands })
  end

end
