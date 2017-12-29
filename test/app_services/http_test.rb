require_relative 'app_services_test_base'

class HttpTest < AppServicesTestBase

  def self.hex_prefix
    'F02B3E'
  end

  # - - - - - - - - - - - - - - - - - - - - -

  test '620',
  'test using runner-stateful' do
    json = http.get('runner_stateful', '4557', 'image_pulled?', {
      image_name:'',
      kata_id:''
    })
    assert_equal({ 'exception' => 'image_name:invalid' }, json)

    json = http.post('runner_stateful', '4557', 'image_pull', {
      image_name:'',
      kata_id:''
    })
    assert_equal({ 'exception' => 'image_name:invalid' }, json)
  end

  # - - - - - - - - - - - - - - - - - - - - -

  test '621',
  'test using runner-stateless' do
    json = http.get('runner_stateless', '4597', 'image_pulled?', {
      image_name:'',
      kata_id:''
    })
    assert_equal({ 'exception' => 'image_name:invalid' }, json)

    json = http.post('runner_stateless', '4597', 'image_pull', {
      image_name:'',
      kata_id:''
    })
    assert_equal({ 'exception' => 'image_name:invalid' }, json)
  end

end
