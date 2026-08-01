require_relative '../../app/services/spooler_service'

# A SpoolerService that raises a SpoolerService::Error on the run_tests-family
# writes. Drives the run_tests rescue path for a transient spooler failure
# (spooler down/overloaded/500/reset). Injected by poking externals' @spooler.
class SpoolerRanTestsRaisesStub < SpoolerService

  MESSAGE = 'spooler unavailable'

  def kata_ran_tests(*)
    raise SpoolerService::Error, MESSAGE
  end

  def kata_predicted_right(*)
    raise SpoolerService::Error, MESSAGE
  end

  def kata_predicted_wrong(*)
    raise SpoolerService::Error, MESSAGE
  end

end
