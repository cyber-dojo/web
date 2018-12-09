require_relative 'app_services_test_base'

class PorterServiceTest < AppServicesTestBase

  def self.hex_prefix
    '71h'
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - -

  test '8z2',
  'smoke test porter.sha' do
    assert_sha porter.sha
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - -

  test '8z3',
  'smoke test porter.port' do
    assert_equal '', porter.port('334455')
  end

end
