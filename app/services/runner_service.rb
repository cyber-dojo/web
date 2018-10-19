require_relative 'http_helper'

class RunnerService

  def initialize(externals)
    @externals = externals
  end

  # - - - - - - - - - - - - - - - - - - - - - - - -

  def sha(runner_name)
    case runner_name
    when 'stateless' then set_hostname_port_stateless
    when 'stateful'  then set_hostname_port_stateful
    end
    http_get(__method__)
  end

  def set_hostname_port_stateless
    @hostname = 'runner-stateless'
    @port = 4597
  end

  def set_hostname_port_stateful
    @hostname = 'runner-stateful'
    @port = 4557
  end

  # - - - - - - - - - - - - - - - - - - - - - - - -

  def kata_new(image_name, id, starting_files)
    unless stateless?(id)
      runner_http_post(__method__, *args(binding))
    end
  end

  def kata_old(image_name, id)
    unless stateless?(id)
      runner_http_post(__method__, *args(binding))
    end
  end

  # - - - - - - - - - - - - - - - - - - - - - - - -

  def run_cyber_dojo_sh(image_name, id, max_seconds, delta, files)
    # This does NOT make a call to singler to get the runner-choice.
    # Assumes appropriate set_hostname_port_X method has already been called.
    new_files = files.select { |filename|
      delta[:new].include?(filename)
    }
    deleted_files = Hash[
      delta[:deleted].map { |filename| [filename, ''] }
    ]
    changed_files = files.select { |filename|
      delta[:changed].include?(filename)
    }
    unchanged_files = files.select { |filename|
      delta[:unchanged].include?(filename)
    }

    args = {
             image_name:image_name,
                     id:id,
              new_files:new_files,
          deleted_files:deleted_files,
          changed_files:changed_files,
        unchanged_files:unchanged_files,
            max_seconds:max_seconds
    }
    tuple = http_post_hash(:run_cyber_dojo_sh, args)
    [tuple['stdout'],
     tuple['stderr'],
     tuple['status'],
     tuple['colour'],
     tuple['new_files'],
     tuple['deleted_files'],
     tuple['changed_files']
   ]
  end

  private # = = = = = = = = = = = = = = = = = = = = =

  def runner_http_post(method, *args)
    set_hostname_port(args[1])
    http_post(method, *args)
  end

  #include HttpHelper

  attr_reader :hostname, :port

  def set_hostname_port(id)
    case runner_choice(id)
    when 'stateless'
      set_hostname_port_stateless
    when 'stateful'
      set_hostname_port_stateful
    end
  end

  def stateless?(id)
    runner_choice(id) == 'stateless'
  end

  def runner_choice(id)
    katas[id].manifest.runner_choice
  end

  def katas
    @externals.katas
  end

  def args(callers_binding)
    callers_name = caller[0][/`.*'/][1..-2]
    method(callers_name).parameters.map do |_, arg_name|
      callers_binding.local_variable_get(arg_name)
    end
  end

end
