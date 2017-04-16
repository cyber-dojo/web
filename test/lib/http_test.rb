require_relative 'lib_test_base'

class HttpTest < LibTestBase

  test 'F02B3620',
  'smoke test http.get and http.post against runner-service' do
    json = http.get('runner', '4557', 'image_pulled?', {
      image_name:'',
      kata_id:''
    })
    assert_equal({ 'exception' => 'image_name:invalid' }, json)

    json = http.post('runner', '4557', 'image_pull', {
      image_name:'',
      kata_id:''
    })
    assert_equal({ 'exception' => 'image_name:invalid' }, json)
  end

end
