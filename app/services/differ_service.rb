# frozen_string_literal: true

require_relative 'http_json/service'
require_relative 'differ_exception'

class DifferService

  def initialize(externals)
    @http = HttpJson::service(externals.http, 'differ', 4567, DifferException)
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
