require_relative '../../app/services/saver_service'

# A SaverService that behaves normally for setup/reads via its inherited methods,
# but raises a NON-"Out of order event" SaverService::Error on the run_tests
# save. Drives the run_tests rescue path for a transient saver failure (saver
# down/overloaded/500/reset), which is distinct from an out-of-order (mobbing)
# rejection. Injected via CYBER_DOJO_SAVER_CLASS.
class SaverRanTestsRaisesStub < SaverService

  MESSAGE = 'saver unavailable'

  def kata_ran_tests(*)
    raise SaverService::Error, MESSAGE
  end

  def kata_predicted_right(*)
    raise SaverService::Error, MESSAGE
  end

  def kata_predicted_wrong(*)
    raise SaverService::Error, MESSAGE
  end

end
