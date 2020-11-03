# frozen_string_literal: true
require_relative 'http_json/requester'
require_relative 'http_json/responder'

class DifferService

  class Error < RuntimeError
    def initialize(message)
      super
    end
  end

  def initialize(externals)
    name = 'differ'
    port = ENV['CYBER_DOJO_DIFFER_PORT'].to_i
    requester = HttpJson::Requester.new(externals.http, name, port)
    @http = HttpJson::Responder.new(requester, Error, {keyed:true})
  end

  def ready?
    @http.get(__method__, {})
  end

  def diff(id, old_files, new_files) # TODO: Delete
    @http.get(__method__, {
      id:id,
      old_files:old_files,
      new_files:new_files
    })
  end

  def diff_lines2(id, old_files, new_files) # temporary
    @http.get(__method__, {
      id:id,
      old_files:old_files,
      new_files:new_files
    })
  end

  #def diff_lines(id, was_index, now_index) # planned
  #  @http.get(__method__, {
  #    id:id,
  #    was_index:was_index,
  #    now_index:now_index
  #  })
  #end

  # diff_summary() is called directly from .js in a $.getJSON() request
  # which nginx reroutes to the differ-service.

end
