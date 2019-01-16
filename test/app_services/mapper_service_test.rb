require_relative 'app_services_test_base'

class MapperServiceTest < AppServicesTestBase

  def self.hex_prefix
    'a47'
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - -

  test '8z1',
  'smoke test mapper' do
    assert mapper.ready?
    assert_sha mapper.sha
    refute mapper.mapped?('112233')
    assert_equal '332211', mapper.mapped_id('332211')
  end

end
