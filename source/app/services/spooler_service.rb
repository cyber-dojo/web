require_relative 'http_json/requester'
require_relative 'http_json/responder'

class SpoolerService

  class Error < RuntimeError
    def initialize(message)
      super
    end
  end

  def initialize(externals)
    @externals = externals
    hostname = ENV.fetch('CYBER_DOJO_SPOOLER_HOSTNAME', 'spooler')
    port = ENV['CYBER_DOJO_SPOOLER_PORT'].to_i
    requester = HttpJson::Requester.new(externals.http, hostname, port)
    @http = HttpJson::Responder.new(requester, Error)
  end

  def ready?
    @http.get(__method__, {})
  end

  # - - - - - - - - - - - - - - - - - -
  # The nine event writes. Each POST durably appends to the spooler's buffer and
  # acks (async); the spooler's drainer forwards to saver in tab_seq order. Reads
  # and non-event writes stay direct web->saver (SaverService).

  def kata_file_create(id, files, filename, laptop_id, tab_seq)
    @http.post(__method__, {
      id:id,
      files:files,
      filename:filename,
      laptop_id:laptop_id,
      tab_seq:tab_seq
    })
  end

  def kata_file_delete(id, files, filename, laptop_id, tab_seq)
    @http.post(__method__, {
      id:id,
      files:files,
      filename:filename,
      laptop_id:laptop_id,
      tab_seq:tab_seq
    })
  end

  def kata_file_rename(id, files, old_filename, new_filename, laptop_id, tab_seq)
    @http.post(__method__, {
      id:id,
      files:files,
      old_filename:old_filename,
      new_filename:new_filename,
      laptop_id:laptop_id,
      tab_seq:tab_seq
    })
  end

  def kata_file_edit(id, files, laptop_id, tab_seq)
    @http.post(__method__, {
      id:id,
      files:files,
      laptop_id:laptop_id,
      tab_seq:tab_seq
    })
  end

  # - - - - - - - - - - - - - - - - - -

  def kata_ran_tests(id, files, stdout, stderr, status, summary, laptop_id, tab_seq)
    @http.post(__method__, {
      id:id,
      files:files,
      stdout:stdout,
      stderr:stderr,
      status:status,
      summary:summary,
      laptop_id:laptop_id,
      tab_seq:tab_seq
    })
  end

  def kata_predicted_right(id, files, stdout, stderr, status, summary, laptop_id, tab_seq)
    @http.post(__method__, {
      id:id,
      files:files,
      stdout:stdout,
      stderr:stderr,
      status:status,
      summary:summary,
      laptop_id:laptop_id,
      tab_seq:tab_seq
    })
  end

  def kata_predicted_wrong(id, files, stdout, stderr, status, summary, laptop_id, tab_seq)
    @http.post(__method__, {
      id:id,
      files:files,
      stdout:stdout,
      stderr:stderr,
      status:status,
      summary:summary,
      laptop_id:laptop_id,
      tab_seq:tab_seq
    })
  end

  def kata_reverted(id, files, stdout, stderr, status, summary, laptop_id, tab_seq)
    @http.post(__method__, {
      id:id,
      files:files,
      stdout:stdout,
      stderr:stderr,
      status:status,
      summary:summary,
      laptop_id:laptop_id,
      tab_seq:tab_seq
    })
  end

  def kata_checked_out(id, files, stdout, stderr, status, summary, laptop_id, tab_seq)
    @http.post(__method__, {
      id:id,
      files:files,
      stdout:stdout,
      stderr:stderr,
      status:status,
      summary:summary,
      laptop_id:laptop_id,
      tab_seq:tab_seq
    })
  end

end
