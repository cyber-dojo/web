require_relative 'app_services_test_base'

class RaggerServiceTest < AppServicesTestBase

  def self.hex_prefix
    'B96'
  end

  def hex_setup
    set_runner_class('RunnerService')
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - -

  test '3A6', 'RaggerExceptionRaiser raises RaggerException' do
    set_ragger_class('RaggerExceptionRaiser')
    error = assert_raises(RaggerException) { ragger.sha }
    assert error.message.start_with?('stub-raiser'), error.message
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - -

  test '3A7',
  'response.body failure is mapped to RaggerException' do
    set_http(HttpJsonRequestPackerNotJsonStub)
    error = assert_raises(RaggerException) { ragger.sha }
    assert error.message.start_with?('http response.body is not JSON'), error.message
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - -

  test '3A8', 'smoke test ready?' do
    assert ragger.ready?
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - -

  test 'F84', 'smoke test ragger.sha' do
    assert_sha(ragger.sha)
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - -

  test 'F85', 'smoke test ragger.colour() == red' do
    stdout = 'Test Count: 3, Passed: 2, Failed: 1, Warnings: 0, Inconclusive: 0, Skipped: 0'
    assert_equal 'red', csharp_nunit_colour(stdout)
  end

  test 'F86', 'smoke test ragger.colour() == amber' do
    stdout = 'once upon a time...'
    assert_equal 'amber', csharp_nunit_colour(stdout)
  end

  test 'F87', 'smoke test ragger.colour() == green' do
    stdout = 'Overall result: Passed'
    assert_equal 'green', csharp_nunit_colour(stdout)
  end

  private

  def csharp_nunit_colour(stdout)
    args = []
    args << (image_name = 'cyberdojofoundation/csharp_nunit')
    args << kata_id
    args << stdout
    args << (stderr = '')
    args << (status = 0)
    ragger.colour(*args)
  end

end
