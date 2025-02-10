require_relative 'app_controller_test_base'

class ReverterTest  < AppControllerTestBase

  def self.hex_prefix
    '81F'
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - - -

  test '276', %w(
  in individual kata, revert back to our own previous traffic-light
  ) do
    in_kata {
      filename = 'hiker.sh'
      change_file(filename, old_content='the_answer')
      post_run_tests # 1
      assert_equal old_content, kata.event(-1)['files'][filename]['content']
      change_file(filename, new_content='something_different')
      post_run_tests # 2
      assert_equal new_content, kata.event(-1)['files'][filename]['content']

      post '/kata/revert', params: {
        'src_id' => kata.id,
        'src_index' => 1,
        'id'     => kata.id,
        'index'  => 3,
        'format' => 'json'
      }
      assert_response :success

      files = json['files']
      refute_nil files
      refute_nil files[filename]
      assert_equal old_content, files[filename]

      assert_equal 4, kata.events.size
      event = kata.event(3)
      assert_equal old_content, event['files'][filename]['content']
      expected = [kata.id,1]
      assert_equal expected, event['revert']
    }
  end

end
