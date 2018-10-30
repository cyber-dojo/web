require_relative 'http_helper'

class RunnerService

  def initialize(externals)
    @externals = externals
  end

  # - - - - - - - - - - - - - - - - - - - - - - - -

  def sha(runner_choice)
    http(runner_choice).get(__method__)
  end

  # - - - - - - - - - - - - - - - - - - - - - - - -

  def kata_new(image_name, id, starting_files)
    http(runner_choice(id)).post(__method__, image_name, id, starting_files)
  end

  # - - - - - - - - - - - - - - - - - - - - - - - -

  def kata_old(image_name, id)
    http(runner_choice(id)).post(__method__, image_name, id)
  end

  # - - - - - - - - - - - - - - - - - - - - - - - -

  def run_cyber_dojo_sh(
    image_name, id,
    new_files, deleted_files, changed_files, unchanged_files,
    max_seconds)

    # Get runner-choice from html <input> and not kata's
    # manifest which would make a slower saver-service call.
    runner_choice = @externals.params['runner_choice']

    tuple = http(runner_choice).post(__method__,
      image_name, id,
      new_files, deleted_files, changed_files, unchanged_files,
      max_seconds)

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

  def http(runner_choice)
    case runner_choice
    when 'stateless'
      HttpHelper.new(@externals, self, 'runner-stateless', 4597)
    when 'stateful'
      HttpHelper.new(@externals, self, 'runner-stateful',  4557)
    end
  end

  def runner_choice(id)
    @externals.katas[id].manifest.runner_choice
  end

end
