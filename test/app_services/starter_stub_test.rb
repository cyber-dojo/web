require_relative 'app_services_test_base'

class StarterStubTest < AppServicesTestBase

  def self.hex_prefix
    '8AB303'
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - -

  test '367', %w{
  Stub mirrors Service for language_manifest(Ruby,MiniTest,FizzBuzz)} do
    service = StarterService.new(self)
    master = service.language_manifest('Ruby', 'MiniTest', 'Fizz_Buzz')
    stubber = StarterStub.new(nil)
    stub = stubber.language_manifest('Ruby', 'MiniTest', 'Fizz_Buzz')
    assert_equal stub, master
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - -

  test '368', %w{
  Stub mirrors Service for language_manifest(Ruby,RSpec,FizzBuzz)} do
    service = StarterService.new(self)
    master = service.language_manifest('Ruby', 'RSpec', 'Fizz_Buzz')
    stubber = StarterStub.new(nil)
    stub = stubber.language_manifest('Ruby', 'RSpec', 'Fizz_Buzz')
    assert_equal stub, master
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - -

  test '369', %w{
  Stub mirrors Service for language_manifest(Ruby,Test::Unit,FizzBuzz)} do
    service = StarterService.new(self)
    master = service.language_manifest('Ruby', 'Test::Unit', 'Fizz_Buzz')
    stubber = StarterStub.new(nil)
    stub = stubber.language_manifest('Ruby', 'Test::Unit', 'Fizz_Buzz')
    assert_equal stub, master
  end

end