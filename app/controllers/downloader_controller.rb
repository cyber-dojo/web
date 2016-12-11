
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

    # Create files off /tmp in new format and then tar that
    base_dir = "/tmp/cyber-dojo/new-downloads/#{outer(id)}/#{inner(id)}"
    katas[id].avatars.each do |avatar|
      path = "#{base_dir}/#{avatar.name}"
      disk[path].make

    end

  end

  private

  include IdSplitter

end
