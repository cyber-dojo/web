require_relative 'app_controller_test_base'

class CheckoutTest  < AppControllerTestBase

  def self.hex_prefix
    '7de'
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - - -

  test '176', %w(
  | in individual kata, checkout your own previous traffic-light
  ) do
    filename = 'hiker.sh'
    old_content = 'the_answer'
    new_content = 'something_different'
    in_kata do
      @files[filename] = old_content
      post_run_tests # 1 edit, 2 ran-tests      
      assert_equal old_content, saver.kata_event(@id, -1)['files'][filename]['content']

      @files[filename] = new_content
      post_run_tests # 3 edit, 4 ran-tests
      assert_equal new_content, saver.kata_event(@id, -1)['files'][filename]['content']

      post_json '/kata/checkout', {
        src_id: @id,
        src_avatar_index: '',
        src_index: 2,
        id: @id,
        index: 5
      }
      assert_response :success

      #files = json['files']
      #refute_nil files
      #refute_nil files[filename]
      #assert_equal old_content, files[filename]

      assert_equal 6, kata.events.size
      event = kata.event(5)
      assert_equal old_content, event['files'][filename]['content']

      expected = { 'id' => @id, 'avatarIndex' => '', 'index' => 2 }
      assert_equal expected, event['checkout']
    end
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - - -

  test '177', %w(
  | in group kata, checkout a different avatar's traffic-light
  ) do
    filename = 'hiker.sh'
    new_content = 'and now for something_different'
    in_kata do |lion|
      lion_avatar_index = 28
      @files[filename] = new_content
      post_run_tests # 1

      in_kata do |hippo|
        post_json '/kata/checkout', {
          src_id: lion.id,
          src_avatar_index: lion_avatar_index,
          src_index: 1,
          id: hippo.id,
          index: 1
        }
        assert_response :success

        files = json['files']
        refute_nil files
        refute_nil files[filename]
        assert_equal new_content, files[filename]

        assert_equal 2, hippo.events.size
        checkout_event = hippo.event(-1)
        assert_equal new_content, checkout_event['files'][filename]['content']
        expected = { 'id' => lion.id, 'avatarIndex' => lion_avatar_index, 'index' => 1 }
        assert_equal expected, checkout_event['checkout']
      end
    end
  end

end
