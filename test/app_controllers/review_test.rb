require_relative 'app_controller_test_base'

class ReviewControllerTest < AppControllerTestBase

  def self.hex_prefix
    '1CB'
  end

  #- - - - - - - - - - - - - - - -

  test '443',
  'review existing session' do
    review('5rTJv5', 1, 2)
    assert_response :success
  end

  test '444',
  'review existing session, indexes both -1' do
    review('5rTJv5', -1, -1)
    assert_response :success
  end

  private

  def review(id, was_index, now_index)
    params = { id:id, was_index:was_index, now_index:now_index }
    get '/review/show', params:params, as: :html
    assert_response :success
  end

end
