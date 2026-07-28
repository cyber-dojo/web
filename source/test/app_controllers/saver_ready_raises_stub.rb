require_relative '../../app/services/saver_service'

# A SaverService whose ready? raises, standing in for saver being unreachable.
# Injected via CYBER_DOJO_SAVER_CLASS to drive /status's degraded (503) path,
# where one down dependency is reported false without failing the endpoint.
class SaverReadyRaisesStub < SaverService

  def ready?
    raise SaverService::Error, 'saver unavailable'
  end

end
