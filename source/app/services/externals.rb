require_relative '../../test/app_services/runner_stub'
require_relative '../../lib/time_adapter'
require_relative 'runner_service'
require_relative 'saver_service'

module Externals

  def time
    @time ||= TimeAdapter.new
  end

  def http
    @http ||= Net::HTTP
  end

  # - - - - - - - - - - - - - - -

  def runner
    @runner ||= external('runner')
  end

  def saver
    @saver ||= external('saver')
  end

  private

  def external(caller)
    # See comment below
    key = 'CYBER_DOJO_' + caller.upcase + '_CLASS'
    var = ENV[key] || fail("ENV[#{key}] not set")
    Object.const_get(var).new(self)
  end

end

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# External class-names are set using environment variables.
# This gives tests a way to do Parameterize-From-Above that
# can tunnel through a *deep* stack. In particular, you can set
# an environment variable and then run a controller-test which
# issue GETs/POSTs, which work their way through the rails stack,
# -In-A-Different-Thread-, reaching externals.rb, where the
# specified Substitute class takes effect.
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
