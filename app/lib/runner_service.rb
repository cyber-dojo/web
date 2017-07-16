require_relative 'http_helper'
require_relative 'stripped_image_name'

class RunnerService

  def initialize(parent)
    @parent = parent
  end

  attr_reader :parent

  # - - - - - - - - - - - - - - - - - - - - - - - -

  def image_pulled?(image_name, kata_id)
    runner_http_get(__method__, image_name, kata_id)
  end

  def image_pull(image_name, kata_id)
    runner_http_post(__method__, image_name, kata_id)
  end

  # - - - - - - - - - - - - - - - - - - - - - - - -

  def kata_new(image_name, kata_id)
    if stateful?(image_name)
      runner_http_post(__method__, image_name, kata_id)
    end
  end

  def kata_old(image_name, kata_id)
    if stateful?(image_name)
      runner_http_post(__method__, image_name, kata_id)
    end
  end

  # - - - - - - - - - - - - - - - - - - - - - - - -

  def avatar_new(image_name, kata_id, avatar_name, starting_files)
    if stateful?(image_name)
      runner_http_post(__method__, image_name, kata_id, avatar_name, starting_files)
    end
  end

  def avatar_old(image_name, kata_id, avatar_name)
    if stateful?(image_name)
      runner_http_post(__method__, image_name, kata_id, avatar_name)
    end
  end

  # - - - - - - - - - - - - - - - - - - - - - - - -

  def run(stateful, image_name, kata_id, avatar_name, max_seconds, delta, files)
    args = {
       image_name:image_name,
          kata_id:kata_id,
      avatar_name:avatar_name,
      max_seconds:max_seconds
    }
    if stateful
      args[:deleted_filenames] = delta[:deleted]
      new_files     = files.select { |filename| delta[:new    ].include? filename }
      changed_files = files.select { |filename| delta[:changed].include? filename }
      args[:changed_files] = new_files.merge(changed_files)
    else
      args[:visible_files] = files
    end
    set_hostname_port(stateful)
    sss = http_post_hash(__method__, args)
    [sss['stdout'], sss['stderr'], sss['status'], sss['colour']]
  end

  private

  def runner_http_get(method, *args)
    image_name = args[0]
    set_hostname_port(stateful?(image_name))
    http_get(method, *args)
  end

  def runner_http_post(method, *args)
    image_name = args[0]
    set_hostname_port(stateful?(image_name))
    http_post(method, *args)
  end

  include HttpHelper
  attr_reader :hostname, :port

  def set_hostname_port(stateful)
    @hostname = stateful ? 'runner' : 'runner_stateless'
    @port = stateful ? 4557 : 4597
  end

  def stateful?(image_name)
    !stripped_image_name(image_name).end_with?('stateless')
  end

  include StrippedImageName

end
