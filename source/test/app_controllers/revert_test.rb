require_relative 'app_controller_test_base'

class RevertTest  < AppControllerTestBase

  def self.hex_prefix
    '81F'
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - - -

  test '275', %w(
  | in individual kata, revert back to our own previous traffic-light
  | when there are *NO* file-events since the previous traffic-light 
  ) do
    in_kata do
      filename = 'hiker.sh'
      new_content = 'the_answer'

      @files[filename] = new_content
      post_run_tests # 1==file-edit, 2==ran-tests
      events = kata.events      
      assert_equal 3, kata.events.size
      assert_equal new_content, kata.event(2)['files'][filename]['content']

      post_run_tests # 3==ran-tests (no change to @files)
      events = kata.events      
      assert_equal 4, kata.events.size
      assert_equal new_content, kata.event(3)['files'][filename]['content']

      post_json '/kata/revert', {
        id: @id,
        index: 4 # revert back to 1st traffic-light @[2]
      }
      assert_response :success

      events = kata.events
      assert_equal 5, kata.events.size
      event = kata.event(4)
      expected = [@id, 2]
      assert_equal expected, event['revert']
      assert_equal new_content, event['files'][filename]['content']
    end
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - - -

  test '276', %w(
  | in individual kata, revert back to our own previous traffic-light
  | when there *ARE* file-events since the previous traffic-light
  ) do
    in_kata do
      filename = 'hiker.sh'
      old_content = @files[filename]      
      post_run_tests # 1==ran-tests
      events = kata.events   
      assert_equal 2, kata.events.size
      assert_equal old_content, kata.event(1)['files'][filename]['content']

      new_content = 'something_different'
      @files[filename] = new_content
      post_run_tests # 2==file-edit, 3==ran-tests
      events = kata.events   
      assert_equal 4, kata.events.size
      assert_equal new_content, kata.event(3)['files'][filename]['content']

      post_json '/kata/revert', {
        id: @id,
        index: 4 # revert back to 1st traffic-light @[1]
      }
      assert_response :success

      events = kata.events
      assert_equal 5, kata.events.size
      event = kata.event(4)
      expected = [@id, 1] # actually [@id, 2] 2==4-2
      assert_equal expected, event['revert']
      assert_equal old_content, event['files'][filename]['content']
    end
  end

end
