require_relative 'app_services_test_base'

class StarterStubTest < AppServicesTestBase

  def self.hex_prefix
    '8AB303'
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - -

  test '367', %w{
  Stub mirrors Service for language_manifest('Ruby, MiniTest','Fizz_Buzz')} do
    stubbed = [
      'Ruby, MiniTest',
      'Ruby, RSpec',
      'Ruby, Test::Unit',
      'Java, JUnit'
    ]
    service = StarterService.new(self)
    stubber = StarterStub.new(nil)
    stubbed.each do |display_name|
      master = service.language_manifest(display_name, 'Fizz_Buzz')
      stub = stubber.language_manifest(display_name, 'Fizz_Buzz')
      assert_equal master, stub
    end
  end

end