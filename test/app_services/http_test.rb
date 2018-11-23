require_relative 'app_services_test_base'

class HttpTest < AppServicesTestBase

  def self.hex_prefix
    'F02'
  end

  # - - - - - - - - - - - - - - - - - - - - -

  test '621',
  'test using runner' do
    json = http.post('runner', '4597', 'sha', {})
    assert_nil json['exception']
    assert_sha json['sha']
  end

end
