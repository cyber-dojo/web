require_relative 'services_test_base'

class ExternalsTest < ServicesTestBase

  #- - - - - - - - - - - - - - - - - - - - - - - - - -

  test '2aP2sK',
  'default http-proxy adapter classes' do
    assert runner.is_a?(RunnerStub)
    assert saver.is_a?(SaverService)
    assert spooler.is_a?(SpoolerService)
  end

end
