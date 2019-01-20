require_relative 'app_controller_test_base'

class ReviewControllerTest < AppControllerTestBase

  def self.hex_prefix
    '1CB'
  end

  #- - - - - - - - - - - - - - - -

  test '443',
  'review existing session' do
    assert_review_show('5rTJv5', 1, 2)
    assert_review_show('5rTJv5', -1, -1)
  end

  test '444',
  'review new session' do
    in_kata { |kata|
      post_run_tests # 1
      assert_review_show(kata.id, 0, 1)
      assert_review_show(kata.id, -1, -1)
    }
  end

  private

  def assert_review_show(id, was_index, now_index)
    params = { id:id, was_index:was_index, now_index:now_index }
    get '/review/show', params:params, as: :html
    assert_response :success
  end

end
