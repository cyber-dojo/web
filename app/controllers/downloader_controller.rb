
class DownloaderController < ApplicationController

  def download
    # an id such as 01FE818E68 corresponds to the folder katas/01/FE818E86
    fail "sorry can't do that" if katas[id].nil?

    cd_cmd = "cd #{storer.path}"
    tar_filename = "/tmp/cyber-dojo/downloads/#{id}.tgz"
    tar_cmd = "tar -zcf #{tar_filename} #{outer(id)}/#{inner(id)}"
    system(cd_cmd + ' && ' + tar_cmd)
    send_file tar_filename
    # would like to delete this tar file
    # but download tests untar them to verify
    # it is identical to original
  end

  private

  include IdSplitter

end
