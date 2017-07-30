require_relative 'http_helper'
require_relative '../../lib/nearest_ancestors'

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
    if stateful?(kata_id)
      runner_http_post(__method__, image_name, kata_id)
    end
  end

  def kata_old(image_name, kata_id)
    if stateful?(kata_id)
      runner_http_post(__method__, image_name, kata_id)
    end
  end

  # - - - - - - - - - - - - - - - - - - - - - - - -

  def avatar_new(image_name, kata_id, avatar_name, starting_files)
    if stateful?(kata_id)
      runner_http_post(__method__, image_name, kata_id, avatar_name, starting_files)
    end
  end

  def avatar_old(image_name, kata_id, avatar_name)
    if stateful?(kata_id)
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
    if stateful?(kata_id)
      args[:deleted_filenames] = delta[:deleted]
      new_files     = files.select { |filename| delta[:new    ].include? filename }
      changed_files = files.select { |filename| delta[:changed].include? filename }
      args[:changed_files] = new_files.merge(changed_files)
    else
      args[:visible_files] = files
    end
    set_hostname_port(kata_id)
    sss = http_post_hash(__method__, args)
    [sss['stdout'], sss['stderr'], sss['status'], sss['colour']]
  end

  private

  def runner_http_get(method, *args)
    set_hostname_port(args[1])
    http_get(method, *args)
  end

  def runner_http_post(method, *args)
    set_hostname_port(args[1])
    http_post(method, *args)
  end

  include HttpHelper
  attr_reader :hostname, :port

  def set_hostname_port(kata_id)
    @hostname = stateful?(kata_id) ? 'runner' : 'runner_stateless'
    @port = stateful?(kata_id) ? 4557 : 4597
  end

  def stateful?(kata_id)
    katas[kata_id].runner_choice == 'stateful'
  end

  include NearestAncestors
  def katas; nearest_ancestors(:katas); end

end
