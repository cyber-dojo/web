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
    runner_choice,
    image_name, id,
    created_files, deleted_files, changed_files, unchanged_files,
    max_seconds)

    http(runner_choice).post_hash(__method__, {
             image_name:image_name,
                     id:id,
          created_files:created_files,
          deleted_files:deleted_files,
          changed_files:changed_files,
        unchanged_files:unchanged_files,
            max_seconds:max_seconds
      })
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
