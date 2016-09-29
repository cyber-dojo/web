
class DownloaderController < ApplicationController

  def download
    # an id such as 01FE818E68 corresponds to the folder katas/01/FE818E86
    fail "sorry can't do that" if katas[id].nil?

    cd_cmd = "cd #{storer.path}"
    tar_cmd = "tar -zcf ../downloads/#{id}.tgz #{outer(id)}/#{inner(id)}"
    system(cd_cmd + ' && ' + tar_cmd)
    tar_filename = "#{storer.path}/../downloads/#{id}.tgz"
    send_file tar_filename
    # would like to delete this tar file
    # but download tests untar them to verify
    # it is identical to original
  end

  private

  include IdSplitter

end
