require_relative 'app_services_test_base'

class StarterStubTest < AppServicesTestBase

  def self.hex_prefix
    '8AB'
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
      assert_hash_equal master, stub
    end
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - -

  def assert_hash_equal(lhs, rhs)
    assert_equal(lhs.keys.sort, rhs.keys.sort)
    lhs.keys.sort.each do |key|
      assert_equal lhs[key], rhs[key], key
    end
  end

end
