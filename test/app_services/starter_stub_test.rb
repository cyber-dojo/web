require_relative 'app_services_test_base'

class StarterStubTest < AppServicesTestBase

  def self.hex_prefix
    '8AB303'
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - -

  test '367', %w{
  Stub mirrors Service for language_manifest(Python,py.test,FizzBuzz)} do
    service = StarterService.new(self)
    master = service.language_manifest('Python', 'py.test', 'Fizz_Buzz')
    stubber = StarterStub.new(nil)
    stub = stubber.language_manifest('Python', 'py.test', 'Fizz_Buzz')
    assert_equal stub, master
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - -

  test '368', %w{
  Stub mirrors Service for language_manifest(Python,unittest,FizzBuzz)} do
    service = StarterService.new(self)
    master = service.language_manifest('Python', 'unittest', 'Fizz_Buzz')
    stubber = StarterStub.new(nil)
    stub = stubber.language_manifest('Python', 'unittest', 'Fizz_Buzz')
    assert_equal stub, master
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - -

  test '369', %w{
  Stub mirrors Service for language_manifest(C (gcc),assert,FizzBuzz)} do
    service = StarterService.new(self)
    master = service.language_manifest('C (gcc)', 'assert', 'Fizz_Buzz')
    stubber = StarterStub.new(nil)
    stub = stubber.language_manifest('C (gcc)', 'assert', 'Fizz_Buzz')
    assert_equal stub, master
  end

end