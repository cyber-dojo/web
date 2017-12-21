require_relative 'lib_test_base'

class HttpTest < LibTestBase

  smoke_test 'F02B3620',
  'smoke test runner-stateful' do
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

  smoke_test 'F02B3621',
  'smoke test runner-stateless' do
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
