require_relative 'app_services_test_base'

class StarterStubTest < AppServicesTestBase

  def self.hex_prefix
    '8AB303'
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

end