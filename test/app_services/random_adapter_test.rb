# frozen_string_literal: true
require_relative 'app_services_test_base'

class RandomAdapterTest < AppServicesTestBase

  def self.hex_prefix
    'H7z'
  end

  test 'dd9',
  'smoke test' do
    r = random.rand(42)
    assert r.is_a?(Integer)
  end

end
