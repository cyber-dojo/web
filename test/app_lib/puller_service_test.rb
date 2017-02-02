require_relative 'app_lib_test_base'

class PullerServiceTest < AppLibTestBase

  # These will fail if there is no network connectivity.

  def setup
    super
    set_puller_class('PullerService')
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - -

  test 'D4FCD3',
  'smoke test puller.pull(nil) raises' do
    error = assert_raises { puller.pull(nil) }
    assert error.message.start_with? 'PullerService:pull:docker pull'
  end

  test 'D4FCD4',
  'smoke test puller.pulled?(nil) returns false' do
    refute puller.pulled?(nil)
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - -

  test 'D4F808',
  'smoke test puller-service' do
    refute puller.pulled? 'cyberdojo/non_existant'
    image_name = 'cyberdojofoundation/gcc_assert'
    assert puller.pull image_name
    assert puller.pulled? image_name
  end

end
