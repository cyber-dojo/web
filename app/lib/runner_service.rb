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
    unless stateless?(kata_id)
      runner_http_post(__method__, *args(binding))
    end
  end

  def kata_old(image_name, kata_id)
    unless stateless?(kata_id)
      runner_http_post(__method__, *args(binding))
    end
  end

  # = = = = = = = = = = = = = = = = = = = = = = = =

  def avatar_new(image_name, kata_id, avatar_name, starting_files)
    unless stateless?(kata_id)
      runner_http_post(__method__, *args(binding))
    end
  end

  def avatar_old(image_name, kata_id, avatar_name)
    unless stateless?(kata_id)
      runner_http_post(__method__, *args(binding))
    end
  end

  # = = = = = = = = = = = = = = = = = = = = = = = =

  def run(image_name, kata_id, avatar_name, max_seconds, delta, files)
    # This makes a call to storer to get the runner-choice.
    # Typically get here from resurrection call.
    to_run = 'run_' + runner_choice(kata_id)
    send(to_run, *args(binding))
  end

  # - - - - - - - - - - - - - - - - - - - - - - - -

  def run_stateless(image_name, kata_id, avatar_name, max_seconds, delta, files)
    # This does NOT make a call to storer to get the runner-choice
    set_hostname_port_stateless
    run_cyber_dojo_sh(image_name, kata_id, avatar_name, max_seconds, delta, files)
  end

  # - - - - - - - - - - - - - - - - - - - - - - - -

  def run_stateful(image_name, kata_id, avatar_name, max_seconds, delta, files)
    # This does NOT make a call to storer to get the runner-choice
    set_hostname_port_stateful
    run_cyber_dojo_sh(image_name, kata_id, avatar_name, max_seconds, delta, files)
  end

  # - - - - - - - - - - - - - - - - - - - - - - - -

  def run_cyber_dojo_sh(image_name, kata_id, avatar_name, max_seconds, delta, files)
    new_files = files.select { |filename|
      delta[:new].include?(filename)
    }
    deleted_files = {}
    delta[:deleted].each { |filename|
      deleted_files[filename] = 'lost content'
    }
    changed_files = files.select { |filename|
      delta[:changed].include?(filename)
    }
    unchanged_files = files.select { |filename|
      delta[:unchanged].include?(filename)
    }

    args = {
             image_name:image_name,
                kata_id:kata_id,
            avatar_name:avatar_name,
              new_files:new_files,
          deleted_files:deleted_files,
          changed_files:changed_files,
        unchanged_files:unchanged_files,
            max_seconds:max_seconds
    }
    quad = http_post_hash(:run_cyber_dojo_sh, args)
    [quad['stdout'], quad['stderr'], quad['status'], quad['colour']]
  end

  private # = = = = = = = = = = = = = = = = = = = = =

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
    case runner_choice(kata_id)
    when 'stateless'
      set_hostname_port_stateless
    when 'stateful'
      set_hostname_port_stateful
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

  def stateless?(kata_id)
    runner_choice(kata_id) == 'stateless'
  end

  def runner_choice(kata_id)
    katas[kata_id].runner_choice
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
