require_relative '../../lib/time_adapter'
require_relative 'runner_service'
require_relative 'saver_service'
require_relative 'spooler_service'

# Wires the app to its collaborators. Each is memoized, so a test substitutes
# one by poking its ivar before the first request, eg
#   externals.instance_exec { @runner = RunnerStub.new(externals) }
module WebApp
  class Externals

    # The clock, so a test can hold time still.
    def time
      @time ||= TimeAdapter.new
    end

    # The http library the services make their requests with.
    def http
      @http ||= Net::HTTP
    end

    # - - - - - - - - - - - - - - -

    # Runs a kata's tests in a container. Substituted by class rather than
    # instance, so it is still built lazily: RunnerService captures http when
    # constructed, and a test may substitute the http after choosing the runner.
    def runner
      @runner ||= runner_class.new(self)
    end

    def runner_class
      @runner_class ||= RunnerService
    end

    attr_writer :runner_class

    # Reads committed kata state.
    def saver
      @saver ||= SaverService.new(self)
    end

    # Buffers this app's event writes and drains them on to the saver.
    def spooler
      @spooler ||= SpoolerService.new(self)
    end
  end
end
