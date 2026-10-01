require_source 'saver_service'

# A SaverService whose ready? raises, standing in for saver being unreachable.
# Injected by poking externals' @saver, to drive /status's degraded (503) path,
# where one down dependency is reported false without failing the endpoint.
class SaverReadyRaisesStub < Web::SaverService

  def ready?
    raise Web::SaverService::Error, 'saver unavailable'
  end

end
