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
  # primitives

  def assert(command)
    @http.post(__method__, { command:command })
  end

  def run(command)
    @http.post(__method__, { command:command })
  end

  # - - - - - - - - - - - - - - - - - - -
  # batches

  def assert_all(commands)
    @http.post(__method__, { commands:commands })
  end

  def run_all(commands)
    @http.post(__method__, { commands:commands })
  end

  def run_until_true(commands)
    @http.post(__method__, { commands:commands })
  end

  def run_until_false(commands)
    @http.post(__method__, { commands:commands })
  end

end
