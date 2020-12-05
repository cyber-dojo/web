# frozen_string_literal: true
require_relative '../../test/app_services/runner_stub'
require_relative '../../test/app_services/saver_raiser'
require_relative '../../lib/time_adapter'
require_relative 'model_service'
require_relative 'runner_service'
require_relative 'saver_service'

module Externals # mix-in

  def time
    @time ||= TimeAdapter.new
  end

  def http
    @http ||= Net::HTTP
  end

  # - - - - - - - - - - - - - - -

  def model
    @model ||= external
  end

  def runner
    @runner ||= external
  end

  def saver
    @saver ||= external
  end

  private

  def external
    # See comment below
    key = 'CYBER_DOJO_' + name_of(caller).upcase + '_CLASS'
    var = ENV[key] || fail("ENV[#{key}] not set")
    Object.const_get(var).new(self)
  end

  def name_of(caller)
    # eg caller[0] == "externals.rb:36:in `runner'"
    /`(?<name>[^']*)/ =~ caller[0] && name
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
