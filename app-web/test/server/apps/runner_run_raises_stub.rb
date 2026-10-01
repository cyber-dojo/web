require 'json'
require_source 'runner_service'

# A RunnerService whose run_cyber_dojo_sh raises a RunnerService::Error carrying
# the message HttpJson::Responder builds from runner's refusal of an untagged
# image_name. Injected by poking externals' @runner.
class RunnerRunRaisesStub < Web::RunnerService

  MESSAGE = JSON.pretty_generate({
    'path' => '/run_cyber_dojo_sh',
    'class' => 'Runner',
    'message' => 'unversioned image_name',
    'backtrace' => [
      '/runner/source/server/dispatcher.rb:28:in `rescue in call\'',
      '/runner/source/server/rack_dispatcher.rb:15:in `call\''
    ]
  })

  def run_cyber_dojo_sh(*)
    raise Web::RunnerService::Error, MESSAGE
  end

end
