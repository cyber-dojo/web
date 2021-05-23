require_relative 'app_controller_test_base'

class CheckoutTest  < AppControllerTestBase

  def self.hex_prefix
    '7de'
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - - -

  test '176', %w(
  in individual kata, checkout our own previous traffic-light
  ) do
    in_kata {
      filename = 'hiker.sh'
      change_file(filename, old_content='the_answer')
      post_run_tests # 1
      assert_equal old_content, saver.kata_event(kata.id,-1)['files'][filename]['content']
      change_file(filename, new_content='something_different')
      post_run_tests # 2
      assert_equal new_content, saver.kata_event(kata.id,-1)['files'][filename]['content']

      post '/kata/checkout', params: {
        'src_id' => kata.id,
        'src_avatar_index' => '',
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

      expected = { "id" => kata.id, "avatarIndex" => "", "index" => 1 }
      assert_equal expected, event['checkout']
    }
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - - -

  test '177', %w(
  in group kata, checkout a different avatar's traffic-light
  ) do
    new_content = 'and now for something_different'
    in_kata do |lion|
      lion_avatar_index = 28
      filename = 'hiker.sh'
      change_file(filename, new_content)
      post_run_tests # 1

      in_kata do |hippo|
        post '/kata/checkout', params: {
          'src_id' => lion.id,
          'src_avatar_index' => lion_avatar_index,
          'src_index' => 1,
          'id'     => hippo.id,
          'index'  => 2,
          'format' => 'json'
        }
        assert_response :success

        files = json['files']
        refute_nil files
        refute_nil files[filename]
        assert_equal new_content, files[filename]

        assert_equal 2, hippo.events.size
        checkout_event = hippo.event(-1)
        assert_equal new_content, checkout_event['files'][filename]['content']
        expected = { "id" => lion.id, "avatarIndex" => lion_avatar_index, "index" => 1 }
        assert_equal expected, checkout_event['checkout']
      end
    end
  end

end
