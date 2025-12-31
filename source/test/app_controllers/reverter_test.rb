require_relative 'app_controller_test_base'

class ReverterTest  < AppControllerTestBase

  def self.hex_prefix
    '81F'
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - - -

  test '276', %w(
  in individual kata, revert back to our own previous traffic-light
  ) do
    in_kata do
      filename = 'hiker.sh'
      old_content = 'the_answer'
      new_content = 'something_different'

      @files[filename] = old_content
      post_run_tests # 1 edit, 2 ran-tests
      assert_equal old_content, kata.event(-1)['files'][filename]['content']

      @files[filename] = new_content
      post_run_tests # 3 edit, 4 ran-tests
      assert_equal new_content, kata.event(-1)['files'][filename]['content']

      events = kata.events      
      assert_equal 5, kata.events.size

      post_json '/kata/revert', {
        'src_id' => @id,
        'src_index' => 2, # revert back to 1st traffic-light
        'id'     => @id,
        'index'  => 5
      }
      assert_response :success

      #files = json['files']
      #refute_nil files
      #refute_nil files[filename]
      #assert_equal old_content, files[filename]

      events = kata.events
      assert_equal 6, kata.events.size
      event = kata.event(5)
      expected = [@id, 2] # actually [@id, 3] 3==5-2
      assert_equal expected, event['revert']
      assert_equal old_content, event['files'][filename]['content']
    end
  end

end
