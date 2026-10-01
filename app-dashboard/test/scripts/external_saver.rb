require_relative 'require_source'
require_source 'external_http'
require_source 'http_json_hash/service'

# Saver microservice
class ExternalSaver
  def initialize
    hostname = 'saver'
    port = ENV.fetch('CYBER_DOJO_SAVER_PORT')
    @http = DashboardApp::HttpJsonHash.service(self.class.name, DashboardApp::ExternalHttp.new, hostname, port)
  end

  def ready?
    @http.get(__method__, {})
  end

  def group_create(manifest)
    @http.post(__method__, { manifest: manifest })
  end 

  def group_manifest(id)
    @http.get(__method__, { id: id })
  end

  def group_join(id)
    @http.post(__method__, { id: id })
  end

  def group_joined(id)
    @http.get(__method__, { id: id })
  end

  def kata_events(id)
    @http.get(__method__, { id: id })
  end

  def katas_events(ids, indexes)
    @http.get(__method__, { ids: ids, indexes: indexes })
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  def kata_file_create(id, files, filename, laptop_id, tab_seq)
    @http.post(__method__,
    { # rubocop:disable Layout/ArgumentAlignment
      id: id,
      files: files,
      filename: filename,
      laptop_id: laptop_id,
      tab_seq: tab_seq
    })
  end

  def kata_file_delete(id, files, filename, laptop_id, tab_seq)
    @http.post(__method__,
    { # rubocop:disable Layout/ArgumentAlignment
      id: id,
      files: files,
      filename: filename,
      laptop_id: laptop_id,
      tab_seq: tab_seq
    })
  end

  def kata_file_rename(id, files, old_filename, new_filename, laptop_id, tab_seq)
    @http.post(__method__,
    { # rubocop:disable Layout/ArgumentAlignment
      id: id,
      files: files,
      old_filename: old_filename,
      new_filename: new_filename,
      laptop_id: laptop_id,
      tab_seq: tab_seq
    })
  end

  def kata_file_edit(id, files, laptop_id, tab_seq)
    @http.post(__method__, { id: id, files: files, laptop_id: laptop_id, tab_seq: tab_seq })
  end

  def kata_ran_tests(id, files, stdout, stderr, status, summary, laptop_id, tab_seq)
    @http.post(__method__,
    { # rubocop:disable Layout/ArgumentAlignment
      id: id,
      files: files,
      stdout: stdout,
      stderr: stderr,
      status: status,
      summary: summary,
      laptop_id: laptop_id,
      tab_seq: tab_seq
    })
  end
end
