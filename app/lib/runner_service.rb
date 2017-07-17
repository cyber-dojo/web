require_relative 'http_helper'

class RunnerService

  def initialize(parent)
    @parent = parent
    @runner_choice = 'stateful'
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

  def running_statefully?
    @runner_choice == 'stateful'
  end

  def run_statefully
    @runner_choice = 'stateful'
  end

  def run_statelessly
    @runner_choice = 'stateless'
  end

  # - - - - - - - - - - - - - - - - - - - - - - - -

  def kata_new(image_name, kata_id)
    if running_statefully?
      runner_http_post(__method__, image_name, kata_id)
    end
  end

  def kata_old(image_name, kata_id)
    if running_statefully?
      runner_http_post(__method__, image_name, kata_id)
    end
  end

  # - - - - - - - - - - - - - - - - - - - - - - - -

  def avatar_new(image_name, kata_id, avatar_name, starting_files)
    if running_statefully?
      runner_http_post(__method__, image_name, kata_id, avatar_name, starting_files)
    end
  end

  def avatar_old(image_name, kata_id, avatar_name)
    if running_statefully?
      runner_http_post(__method__, image_name, kata_id, avatar_name)
    end
  end

  # - - - - - - - - - - - - - - - - - - - - - - - -

  def run(image_name, kata_id, avatar_name, max_seconds, delta, files)
    args = {
       image_name:image_name,
          kata_id:kata_id,
      avatar_name:avatar_name,
      max_seconds:max_seconds
    }
    if running_statefully?
      args[:deleted_filenames] = delta[:deleted]
      new_files     = files.select { |filename| delta[:new    ].include? filename }
      changed_files = files.select { |filename| delta[:changed].include? filename }
      args[:changed_files] = new_files.merge(changed_files)
    else
      args[:visible_files] = files
    end
    set_hostname_port
    sss = http_post_hash(__method__, args)
    [sss['stdout'], sss['stderr'], sss['status'], sss['colour']]
  end

  private

  def runner_http_get(method, *args)
    set_hostname_port
    http_get(method, *args)
  end

  def runner_http_post(method, *args)
    set_hostname_port
    http_post(method, *args)
  end

  include HttpHelper
  attr_reader :hostname, :port

  def set_hostname_port
    @hostname = running_statefully? ? 'runner' : 'runner_stateless'
    @port = running_statefully? ? 4557 : 4597
  end

end
