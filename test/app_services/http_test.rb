require_relative 'app_services_test_base'

class HttpTest < AppServicesTestBase

  def self.hex_prefix
    'F02B3E'
  end

  # - - - - - - - - - - - - - - - - - - - - -

  test '620',
  'test using runner-stateful' do
    json = http.post('runner-stateful', '4557', 'kata_new', {
      image_name:'',
      kata_id:''
    })
    assert_equal 'image_name:malformed', json['exception']
  end

  # - - - - - - - - - - - - - - - - - - - - -

  test '621',
  'test using runner-stateless' do
    json = http.post('runner-stateless', '4597', 'kata_new', {
      image_name:'',
      kata_id:''
    })
    ex = json['exception']
    assert_equal 'ClientError', ex['class']
    assert_equal 'image_name:malformed', ex['message']
    assert_equal 'Array', ex['backtrace'].class.name
  end

end
