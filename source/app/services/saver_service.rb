require_relative 'http_json/requester'
require_relative 'http_json/responder'

class SaverService

  class Error < RuntimeError
    def initialize(message)
      super
    end
  end

  def initialize(externals)
    @externals = externals
    hostname = ENV.fetch('CYBER_DOJO_SAVER_HOSTNAME', 'saver')
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

  def group_fork(id, index)
    @http.post(__method__, {id:id, index:index})
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

  def kata_fork(id, index)
    @http.post(__method__, {id:id, index:index})
  end

  def kata_events(id)
    @http.get(__method__, {id:id})
  end

  def kata_download(id)
    @http.get(__method__, {id:id})
  end

  def kata_option_get(id, name)
    @http.get(__method__, {id:id, name:name})
  end

  def kata_option_set(id, name, value)
    @http.post(__method__, {id:id, name:name, value:value})
  end

  def kata_event(id, index)
    @http.get(__method__, {id:id, index:index})
  end

  # - - - - - - - - - - - - - - - - - -

  def kata_file_create(id, files, filename, laptop_id)
    @http.post(__method__, {
      id:id,
      files:files,
      filename:filename,
      laptop_id:laptop_id
    })
  end

  def kata_file_delete(id, files, filename, laptop_id)
    @http.post(__method__, {
      id:id,
      files:files,
      filename:filename,
      laptop_id:laptop_id
    })
  end

  def kata_file_rename(id, files, old_filename, new_filename, laptop_id)
    @http.post(__method__, {
      id:id, 
      files:files,
      old_filename:old_filename,
      new_filename:new_filename,
      laptop_id:laptop_id
    })
  end

  def kata_file_edit(id, files, laptop_id)
    @http.post(__method__, {
      id:id,
      files:files,
      laptop_id:laptop_id
    })
  end

  # - - - - - - - - - - - - - - - - - -

  def kata_ran_tests(id, files, stdout, stderr, status, summary, laptop_id)
    @http.post(__method__, {
      id:id,
      files:files,
      stdout:stdout,
      stderr:stderr,
      status:status,
      summary:summary,
      laptop_id:laptop_id
    })
  end

  def kata_predicted_right(id, files, stdout, stderr, status, summary, laptop_id)
    @http.post(__method__, {
      id:id,
      files:files,
      stdout:stdout,
      stderr:stderr,
      status:status,
      summary:summary,
      laptop_id:laptop_id
    })
  end

  def kata_predicted_wrong(id, files, stdout, stderr, status, summary, laptop_id)
    @http.post(__method__, {
      id:id,
      files:files,
      stdout:stdout,
      stderr:stderr,
      status:status,
      summary:summary,
      laptop_id:laptop_id
    })
  end

  def kata_reverted(id, files, stdout, stderr, status, summary, laptop_id)
    @http.post(__method__, {
      id:id,
      files:files,
      stdout:stdout,
      stderr:stderr,
      status:status,
      summary:summary,
      laptop_id:laptop_id
    })
  end

  def kata_checked_out(id, files, stdout, stderr, status, summary, laptop_id)
    @http.post(__method__, {
      id:id,
      files:files,
      stdout:stdout,
      stderr:stderr,
      status:status,
      summary:summary,
      laptop_id:laptop_id
    })
  end

  # - - - - - - - - - - - - - - - - - -

  def diff_summary(id, was_index, now_index)
    @http.get(__method__, {id:id, was_index:was_index, now_index:now_index})
  end

  def diff_lines(id, was_index, now_index)
    @http.get(__method__, {id:id, was_index:was_index, now_index:now_index})
  end

end
