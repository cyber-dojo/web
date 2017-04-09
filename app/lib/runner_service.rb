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

  def run(image_name, kata_id, avatar_name, max_seconds, delta, files)
    new_files     = files.select { |filename| delta[:new    ].include? filename }
    changed_files = files.select { |filename| delta[:changed].include? filename }

    sss = http_post_hash(__method__, {
             image_name:image_name,
                kata_id:kata_id,
            avatar_name:avatar_name,
      deleted_filenames:delta[:deleted],
          changed_files:new_files.merge(changed_files),
            max_seconds:max_seconds
    })
    [sss['stdout'], sss['stderr'], sss['status'], sss['colour']]
  end

  private

  include HttpService
  def hostname; 'runner'; end
  def port; 4557; end

end
