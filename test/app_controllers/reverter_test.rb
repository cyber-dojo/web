require_relative 'app_controller_test_base'

class ReverterControllerTest  < AppControllerTestBase

  def self.hex_prefix
    '81F'
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - - -

  test '276',
  'in individual kata, revert back to our own previous traffic-light' do
    in_kata {
      filename = 'hiker.rb'
      change_file(filename, old_content='the_answer')
      post_run_tests # 1
      assert_equal old_content, kata.files[filename]['content']
      change_file(filename, new_content='something_different')
      post_run_tests # 2
      assert_equal new_content, kata.files[filename]['content']

      post '/reverter/revert', params: { # 3
        'format' => 'json',
        'src_id' => kata.id,
        'src_index' => 1,
        'id'     => kata.id,
        'index'  => 3,
      }
      assert_response :success

      files = json['files']
      refute_nil files
      refute_nil files[filename]
      assert_equal old_content, files[filename]

      assert_equal 4, kata.events.size
      event = kata.events[3]
      assert_equal old_content, event.files[filename]['content']
      assert_equal 1, event.revert
    }
  end

end
