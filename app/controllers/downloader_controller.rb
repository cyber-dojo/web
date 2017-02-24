
class DownloaderController < ApplicationController

  def download
    send_file zipper.zip(id)
  end

end
