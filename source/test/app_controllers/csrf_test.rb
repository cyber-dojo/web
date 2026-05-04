require_relative 'app_controller_test_base'

class CsrfTest < AppControllerTestBase

  test 'C5R8T2a',
  'POST with no csrf token returns 403' do
    in_kata do
      get '/alive'
      method(:post).super_method.call('/kata/fork', { id: @id, index: 0 })
      assert_equal 403, last_response.status
    end
  end

  test 'C5R8T2b',
  'POST with tampered csrf token returns 403' do
    in_kata do
      get '/alive'
      method(:post).super_method.call('/kata/fork', {
        id: @id, index: 0, authenticity_token: 'tampered'
      })
      assert_equal 403, last_response.status
    end
  end

end
