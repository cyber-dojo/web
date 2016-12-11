
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
    kata_path = "/tmp/cyber-dojo/new-downloads/#{outer(id)}/#{inner(id)}"
    kata_dir = disk[kata_path]
    kata_dir.make
    kata_dir.write_json('manifest.json', storer.kata_manifest(id))
    katas[id].avatars.each do |avatar|
      avatar_path = "#{kata_path}/#{avatar.name}"
      avatar_dir = disk[avatar_path]
      avatar_dir.make

    end

  end

  private

  include IdSplitter

end
