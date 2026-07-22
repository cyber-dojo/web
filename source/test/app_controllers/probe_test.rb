require_relative 'app_controller_test_base'
require_relative 'saver_ready_raises_stub'

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

  test 'EB4006', %w(
  | /status returns 200 and each dependency's readiness when all are ready
  ) do
    get '/status'
    assert last_response.ok?, last_response.body
    assert_equal(
      { 'status' => { 'runner' => true, 'saver' => true, 'spooler' => true } },
      JSON.parse(last_response.body))
  end

  test 'EB4007', %w(
  | /status returns 503 and marks the unreachable dependency false when one is
  | down, without failing the whole endpoint
  ) do
    set_class('saver', 'SaverReadyRaisesStub')
    get '/status'
    assert_equal 503, last_response.status, last_response.body
    assert_equal(
      { 'status' => { 'runner' => true, 'saver' => false, 'spooler' => true } },
      JSON.parse(last_response.body))
  end

end
