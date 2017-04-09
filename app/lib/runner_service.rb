require_relative 'http_service'

class RunnerService

  def initialize(_parent)
  end

  # - - - - - - - - - - - - - - - - - - - - - - - -

  def image_pulled?(image_name, kata_id)
    runner_http_get(__method__, image_name, kata_id)
  end

  def image_pull(image_name, kata_id)
    runner_http_post(__method__, image_name, kata_id)
  end

  # - - - - - - - - - - - - - - - - - - - - - - - -

  def kata_new(image_name, kata_id)
    runner_http_post(__method__, image_name, kata_id)
  end

  def kata_old(image_name, kata_id)
    runner_http_post(__method__, image_name, kata_id)
  end

  # - - - - - - - - - - - - - - - - - - - - - - - -

  def avatar_new(image_name, kata_id, avatar_name, starting_files)
    runner_http_post(__method__, image_name, kata_id, avatar_name, starting_files)
  end

  def avatar_old(image_name, kata_id, avatar_name)
    runner_http_post(__method__, image_name, kata_id, avatar_name)
  end

  # - - - - - - - - - - - - - - - - - - - - - - - -

  def run(image_name, kata_id, avatar_name, max_seconds, delta, files)
    new_files     = files.select { |filename| delta[:new    ].include? filename }
    changed_files = files.select { |filename| delta[:changed].include? filename }
    set_hostname_from(image_name)
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

  def runner_http_get(method, *args)
    set_hostname_from(image_name = args[0])
    http_get(method, *args)
  end

  def runner_http_post(method, *args)
    set_hostname_from(image_name = args[0])
    http_post(method, *args)
  end

  include HttpService

  def set_hostname_from(image_name)
    @hostname = 'runner'
    #@hostname = 'runner_stateless' if image_name.end_with? ':stateless'
  end

  attr_reader :hostname

  def port; 4557; end

end
