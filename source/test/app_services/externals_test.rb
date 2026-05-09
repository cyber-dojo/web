require_relative 'app_services_test_base'

class ExternalsTest < AppServicesTestBase

  #- - - - - - - - - - - - - - - - - - - - - - - - - -

  test '2aP2sK',
  'default http-proxy adapter classes' do
    assert runner.is_a?(RunnerStub)
    assert saver.is_a?(SaverService)
  end

end
