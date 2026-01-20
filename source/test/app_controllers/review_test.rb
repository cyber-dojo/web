require_relative 'app_controller_test_base'

class ReviewTest < AppControllerTestBase

  def self.hex_prefix
    '1CB'
  end

  #- - - - - - - - - - - - - - - -

  test '440', %w(
  | was_index != now_index
  ) do
    [2].each do |version|
      in_kata(version:version) do |kata|
        post_run_tests # 1
        assert_review_show(kata.id, 0, 1)
      end
    end
  end

  #- - - - - - - - - - - - - - - -

  test '441', %w(
  | (was_index,now_index) == (-1,-1)
  ) do
    [2].each do |version|
      in_kata(version:version) do |kata|
        post_run_tests # 1
        assert_review_show(kata.id, -1, -1)
      end
    end
  end

  #- - - - - - - - - - - - - - - -

  test '442', %w(
  | was_index != now_index, review existing version=0 kata
  ) do
    assert_review_show('5rTJv5', 1, 2)
  end

  test '443', %w(
  | (was_index,now_index) == (-1,-1) review existing version=0 kata 
  ) do
    assert_review_show('5rTJv5', -1, -1)
  end

  #- - - - - - - - - - - - - - - -

  test '444', %w( 
  | was_index != now_index, review new version=1 kata
  ) do
    in_kata { |kata|
      post_run_tests # 1
      assert_review_show(kata.id, 0, 1)
    }
  end

  test '445', %w(
  | (was_index,now_index) == (-1,-1), review new version=1 kata
  ) do
    in_kata { |kata|
      post_run_tests # 1
      assert_review_show(kata.id, -1, -1)
    }
  end

  private

  def assert_review_show(id, was_index, now_index)
    params = { id:id, was_index:was_index, now_index:now_index }
    get '/review/show', params:params
    assert_response :success
  end

end
