require 'base64'

class DownloaderController < ApplicationController

  def download
    encoded = zipper.zip(id)
    filename = "#{id}.tgz"
    send_data Base64.decode64(encoded), :filename => filename
  end

  def download_tag
    avatar_name = kata.avatar_name
    encoded = zipper.zip_tag(id, avatar_name, tag)
    filename = "#{id}_#{avatar_name}_#{tag}.tgz"
    send_data Base64.decode64(encoded), :filename => filename
  end

end
