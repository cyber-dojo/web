require_relative 'http_helper'
require_relative '../../lib/nearest_ancestors'

class RunnerService

  def initialize(parent)
    @parent = parent
  end

  attr_reader :parent

  # = = = = = = = = = = = = = = = = = = = = = = = =

  def image_pulled?(image_name, kata_id)
    runner_http_get(__method__, *args(binding))
  end

  def image_pull(image_name, kata_id)
    runner_http_post(__method__, *args(binding))
  end

  # = = = = = = = = = = = = = = = = = = = = = = = =

  def kata_new(image_name, kata_id)
    if stateful?(kata_id)
      runner_http_post(__method__, *args(binding))
    end
  end

  def kata_old(image_name, kata_id)
    if stateful?(kata_id)
      runner_http_post(__method__, *args(binding))
    end
  end

  # = = = = = = = = = = = = = = = = = = = = = = = =

  def avatar_new(image_name, kata_id, avatar_name, starting_files)
    if stateful?(kata_id)
      runner_http_post(__method__, *args(binding))
    end
  end

  def avatar_old(image_name, kata_id, avatar_name)
    if stateful?(kata_id)
      runner_http_post(__method__, *args(binding))
    end
  end

  # = = = = = = = = = = = = = = = = = = = = = = = =

  def run(image_name, kata_id, avatar_name, max_seconds, delta, files)
    to_run = stateful?(kata_id) ? :run_stateful : :run_stateless
    send(to_run, *args(binding))
  end

  # - - - - - - - - - - - - - - - - - - - - - - - -

  def run_stateful(image_name, kata_id, avatar_name, max_seconds, delta, files)
    new_files = files.select { |filename|
      delta[:new].include? filename
    }
    changed_files = files.select { |filename|
      delta[:changed].include? filename
    }
    args = {
             image_name:image_name,
                kata_id:kata_id,
            avatar_name:avatar_name,
            max_seconds:max_seconds,
      deleted_filenames:delta[:deleted],
          changed_files:new_files.merge(changed_files)
    }
    set_hostname_port_stateful
    quad = http_post_hash(:run, args)
    [quad['stdout'], quad['stderr'], quad['status'], quad['colour']]
  end

  # - - - - - - - - - - - - - - - - - - - - - - - -

  def run_stateless(image_name, kata_id, avatar_name, max_seconds, delta, files)
    args = {
         image_name:image_name,
            kata_id:kata_id,
        avatar_name:avatar_name,
        max_seconds:max_seconds,
      visible_files:files
    }
    set_hostname_port_stateless
    quad = http_post_hash(:run, args)
    [quad['stdout'], quad['stderr'], quad['status'], quad['colour']]
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
    if stateful?(kata_id)
      set_hostname_port_stateful
    else
      set_hostname_port_stateless
    end
  end

  def set_hostname_port_stateful
    @hostname = 'runner_stateful'
    @port = 4557
  end

  def set_hostname_port_stateless
    @hostname = 'runner_stateless'
    @port = 4597
  end

  def stateful?(kata_id)
    katas[kata_id].runner_choice == 'stateful'
  end

  include NearestAncestors

  def katas
    nearest_ancestors(:katas)
  end

  def args(callers_binding)
    callers_name = caller[0][/`.*'/][1..-2]
    method(callers_name).parameters.map do |_, arg_name|
      callers_binding.local_variable_get(arg_name)
    end
  end

end
