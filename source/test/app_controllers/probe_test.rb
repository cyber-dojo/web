require_relative 'app_controller_test_base'

class ProbeTest < AppControllerTestBase

  test 'EB4001', %w(
  | /alive returns 200 with alive?:true
  ) do
    get '/alive'
    assert last_response.ok?
    assert_equal({ 'alive?' => true }, JSON.parse(last_response.body))
  end

  test 'EB4002', %w(
  | /ready returns 200 with ready?:true
  ) do
    get '/ready'
    assert last_response.ok?
    assert_equal({ 'ready?' => true }, JSON.parse(last_response.body))
  end

  test 'EB4004', %w(
  | /alive/ (trailing slash) returns 200 with alive?:true
  ) do
    get '/alive/'
    assert last_response.ok?
    assert_equal({ 'alive?' => true }, JSON.parse(last_response.body))
  end

  test 'EB4005', %w(
  | /ready/ (trailing slash) returns 200 with ready?:true
  ) do
    get '/ready/'
    assert last_response.ok?
    assert_equal({ 'ready?' => true }, JSON.parse(last_response.body))
  end

end
