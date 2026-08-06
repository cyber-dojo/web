require_relative 'app_controller_test_base'

class ReviewTest < AppControllerTestBase

  #- - - - - - - - - - - - - - - -

  test '1CB440', %w(
  | was_index != now_index
  ) do
    in_kata do |kata|
      post_run_tests # 1
      assert_review_show(kata.id, 0, 1)
    end
  end

  #- - - - - - - - - - - - - - - -

  test '1CB441', %w(
  | (was_index,now_index) == (-1,-1)
  ) do
    in_kata do |kata|
      post_run_tests # 1
      assert_review_show(kata.id, -1, -1)
    end
  end

  #- - - - - - - - - - - - - - - -

  test '1CB442', %w(
  | was_index != now_index, review existing version=0 kata
  ) do
    assert_review_show('5rTJv5', 1, 2)
  end

  test '1CB443', %w(
  | (was_index,now_index) == (-1,-1) review existing version=0 kata 
  ) do
    assert_review_show('5rTJv5', -1, -1)
  end

  #- - - - - - - - - - - - - - - -

  test '1CB444', %w(
  | was_index != now_index, review kata
  ) do
    in_kata { |kata|
      post_run_tests # 1
      assert_review_show(kata.id, 0, 1)
    }
  end

  test '1CB445', %w(
  | (was_index,now_index) == (-1,-1), review kata
  ) do
    in_kata { |kata|
      post_run_tests # 1
      assert_review_show(kata.id, -1, -1)
    }
  end

  #- - - - - - - - - - - - - - - -

  test '1CB446', %w(
  | the fork dialog's two buttons POST to the /fork prefix. Nothing
  | functional can pin this while the app also answers the old paths,
  | so the literals in the rendered page are what the test reads.
  ) do
    in_kata do |kata|
      post_run_tests # 1
      get "/review/show/#{kata.id}", { was_index: 0, now_index: 1 }
      assert last_response.ok?
      # Only the lines naming a fork path, so a failure prints those
      # rather than the whole 78K page.
      lines = last_response.body.lines.grep(/fork\(/).join
      assert_includes lines, "fork('/fork/kata'"
      assert_includes lines, "fork('/fork/group'"
      refute_includes lines, '/kata/fork'
      refute_includes lines, '/group/fork'
    end
  end

  private

  def assert_review_show(id, was_index, now_index)
    get "/review/show/#{id}", { was_index: was_index, now_index: now_index }
    assert last_response.ok?
  end

end
