# frozen_string_literal: true

require_relative 'http_json/service'

class DifferService

  class Error < RuntimeError
    def initialize(message)
      super
    end
  end

  def initialize(externals)
    @http = HttpJson::service(externals.http, 'differ', 4567, Error)
  end

  def ready?
    @http.get(__method__, {})
  end

  def sha
    @http.get(__method__, {})
  end

  def diff(id, old_files, new_files)
    @http.get(__method__, {
      id:id,
      old_files:old_files,
      new_files:new_files
    })
  end

end
