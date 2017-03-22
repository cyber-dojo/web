require_relative 'http_service'

class RunnerService

  def initialize(_parent)
  end

  # - - - - - - - - - - - - - - - - - - - - - - - -

  def image_pulled?(image_name, kata_id)
    http_get(__method__, image_name, kata_id)
  end

  def image_pull(image_name, kata_id)
    http_post(__method__, image_name, kata_id)
  end

  # - - - - - - - - - - - - - - - - - - - - - - - -

  def kata_new(image_name, kata_id)
    http_post(__method__, image_name, kata_id)
  end

  def kata_old(image_name, kata_id)
    http_post(__method__, image_name, kata_id)
  end

  # - - - - - - - - - - - - - - - - - - - - - - - -

  def avatar_new(image_name, kata_id, avatar_name, starting_files)
    http_post(__method__, image_name, kata_id, avatar_name, starting_files)
  end

  def avatar_old(image_name, kata_id, avatar_name)
    http_post(__method__, image_name, kata_id, avatar_name)
  end

  # - - - - - - - - - - - - - - - - - - - - - - - -

  def run(image_name, kata_id, avatar_name, deleted_filenames, changed_files, max_seconds)
    args = [image_name, kata_id, avatar_name, deleted_filenames, changed_files, max_seconds]
    sss = http_post(__method__, *args)
    [sss['stdout'], sss['stderr'], sss['status'], sss['colour']]
  end

  private

  include HttpService
  def hostname; 'runner'; end
  def port; 4557; end

end
