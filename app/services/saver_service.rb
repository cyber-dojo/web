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
    hostname = 'saver'
    port = ENV['CYBER_DOJO_SAVER_PORT'].to_i
    requester = HttpJson::Requester.new(externals.http, hostname, port)
    @http = HttpJson::Responder.new(requester, Error)
  end

  def ready?
    @http.get(__method__, {})
  end

  # - - - - - - - - - - - - - - - - - - -

  def dir_make_command(dirname)
    ['dir_make',dirname]
  end

  def dir_exists_command(dirname)
    ['dir_exists?',dirname]
  end

  def file_create_command(filename, content)
    ['file_create',filename,content]
  end

  def file_append_command(filename, content)
    ['file_append',filename,content]
  end

  def file_read_command(filename)
    ['file_read',filename]
  end

  # - - - - - - - - - - - - - - - - - - -

  def run(command)
    @http.post(__method__, { command:command })
  end

  def run_all(commands)
    @http.post(__method__, { commands:commands })
  end

end
