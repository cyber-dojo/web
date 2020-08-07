require_relative 'app_controller_test_base'

class ReverterControllerTest  < AppControllerTestBase

  def self.hex_prefix
    '81F'
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - - -

  test '276', %w(
  in individual kata, revert back to our own previous traffic-light
  ) do
    in_kata {
      filename = 'hiker.rb'
      change_file(filename, old_content='the_answer')
      post_run_tests # 1
      assert_equal old_content, kata.files[filename]['content']
      change_file(filename, new_content='something_different')
      post_run_tests # 2
      assert_equal new_content, kata.files[filename]['content']

      post '/reverter/revert', params: { # 3
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
      event = kata.events[3]
      assert_equal old_content, event.files[filename]['content']
      assert_equal [kata.id,1], event.revert
    }
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - - -

  test '277', %w(
  in group kata, revert back to a different avatar's traffic-light
  ) do
    new_content = 'and now for something_different'

    in_kata do |lion|
      filename = 'hiker.rb'
      change_file(filename, new_content)
      post_run_tests # 1

      in_kata do |hippo|
        post '/reverter/revert', params: { # 1
          'src_id' => lion.id,
          'src_index' => 1,
          'id'     => hippo.id,
          'index'  => 1,
          'format' => 'json'
        }
        assert_response :success

        files = json['files']
        refute_nil files
        refute_nil files[filename]
        assert_equal new_content, files[filename]

        assert_equal 2, hippo.events.size
        revert_event = hippo.events.last
        assert_equal new_content, revert_event.files[filename]['content']
        assert_equal [lion.id,1], revert_event.revert
      end
    end
  end

end
