require 'json'
require 'net/http'
require_relative 'http_service'

class RunnerService

  def initialize(_parent)
  end

  def pulled?(image_name)
    pulled(image_name)
  end

  def pulled(image_name)
    get(__method__, image_name)
  end

  def pull(image_name)
    post(__method__, image_name)
  end

  def new_kata(image_name, kata_id)
    post(__method__, image_name, kata_id)
  end

  def new_avatar(image_name, kata_id, avatar_name, starting_files)
    post(__method__, image_name, kata_id, avatar_name, starting_files)
  end

  def run(image_name, kata_id, avatar_name, deleted_filenames, changed_files, max_seconds)
    args = []
    args << image_name
    args << kata_id
    args << avatar_name
    args << deleted_filenames
    args << changed_files
    args << max_seconds
    sss = post(__method__, *args)
    [sss['stdout'], sss['stderr'], sss['status']]
  end

  def old_avatar(kata_id, avatar_name)
    post(__method__, kata_id, avatar_name)
  end

  def old_kata(kata_id)
    post(__method__, kata_id)
  end

  private

  include HttpService
  def hostname; 'runner'; end
  def port; 4557; end

end
