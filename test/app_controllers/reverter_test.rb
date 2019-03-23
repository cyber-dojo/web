require_relative 'app_controller_test_base'

class ReverterControllerTest  < AppControllerTestBase

  def self.hex_prefix
    '81F'
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - - -

  test '276',
  'revert' do
    in_kata {
      filename = 'hiker.rb'
      change_file(filename, old_content='the_answer')
      post_run_tests # 1
      assert_equal old_content, kata.files[filename]['content']
      change_file(filename, new_content='something_different')
      post_run_tests # 2
      assert_equal new_content, kata.files[filename]['content']

      get '/reverter/revert', params: {
        'format' => 'json',
        'id'     => kata.id,
        'index'  => 1
      }
      assert_response :success

      visible_files = json['visibleFiles']
      refute_nil visible_files

      refute_nil visible_files['stdout']
      refute_nil visible_files['stderr']
      refute_nil visible_files[filename]
      assert_equal old_content, visible_files[filename]
    }
  end

end
