require_relative 'app_controller_test_base'

class LaptopIdCookieTest < AppControllerTestBase

  test 'F2a9C1a',
  'a request with no laptop_id cookie mints one (64-char hex), mirroring csrf_token' do
    assert_nil rack_mock_session.cookie_jar['laptop_id']
    get '/alive'
    laptop_id = rack_mock_session.cookie_jar['laptop_id']
    refute_nil laptop_id, 'laptop_id cookie was not set'
    assert_match(/\A[0-9a-f]{64}\z/, laptop_id, laptop_id)
  end

  test 'F2a9C1b',
  'the laptop_id cookie is stable across reloads (a refresh keeps the same id)' do
    get '/alive'
    first = rack_mock_session.cookie_jar['laptop_id']
    refute_nil first
    get '/alive'
    second = rack_mock_session.cookie_jar['laptop_id']
    assert_equal first, second, 'laptop_id changed across reloads'
  end

end
