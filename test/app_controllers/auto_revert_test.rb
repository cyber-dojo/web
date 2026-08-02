require_relative 'app_controller_test_base'

class AutoRevertTest < AppControllerTestBase

  # - - - - - - - - - - - - - - - - - - - - - - - - - - -

  test '81F274', %w(
  | in individual kata, revert back to index=0 (created)
  | when there are *NO* file-events since creation
  ) do
    in_kata do
      post_run_tests # 1==ran-tests
      assert_equal 2, kata.events.size

      post_json '/kata/auto_revert', {
        id: @id,
        tab_seq: next_tab_seq
      }
      assert last_response.successful?

      assert_equal 3, kata.events.size
      event = kata.event(2)
      expected = [@id, 0]
      assert_equal expected, event['revert']
      assert_equal 'create', event['colour']
      assert_equal 'create', json['light']['colour']
    end
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - - -

  test '81F275', %w(
  | in individual kata, revert back to our own previous traffic-light
  | when there are *NO* file-events since the previous traffic-light 
  ) do
    in_kata do
      filename = 'hiker.sh'
      new_content = 'the_answer'

      @files[filename] = new_content
      post_run_tests # 1==file-edit, 2==ran-tests
      assert_equal 3, kata.events.size
      assert_equal new_content, kata.event(2)['files'][filename]['content']

      post_run_tests # 3==ran-tests (no change to @files)
      assert_equal 4, kata.events.size
      assert_equal new_content, kata.event(3)['files'][filename]['content']

      post_json '/kata/auto_revert', {
        id: @id,
        tab_seq: next_tab_seq
      }
      assert last_response.successful?

      assert_equal 5, kata.events.size
      event = kata.event(4)
      expected = [@id, 2]
      assert_equal expected, event['revert']
      assert_equal new_content, event['files'][filename]['content']
      assert_equal 'red', json['light']['colour']
    end
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - - -

  test '81F276', %w(
  | in individual kata, revert back to our own previous traffic-light
  | when there *ARE* file-events since the previous traffic-light
  ) do
    in_kata do
      filename = 'hiker.sh'
      old_content = @files[filename]      
      post_run_tests # 1==ran-tests
      assert_equal 2, kata.events.size
      assert_equal old_content, kata.event(1)['files'][filename]['content']

      new_content = 'something_different'
      @files[filename] = new_content
      post_run_tests # 2==file-edit, 3==ran-tests
      assert_equal 4, kata.events.size
      assert_equal new_content, kata.event(3)['files'][filename]['content']

      post_json '/kata/auto_revert', {
        id: @id,
        tab_seq: next_tab_seq
      }
      assert last_response.successful?

      assert_equal 5, kata.events.size
      event = kata.event(4)
      expected = [@id, 1] # actually [@id, 2] 2==4-2
      assert_equal expected, event['revert']
      assert_equal old_content, event['files'][filename]['content']
      assert_equal 'red', json['light']['colour']
    end
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - - -

  test '81F277', %w(
  | in individual kata, revert back to our own previous traffic-light
  | when the previous traffic-light was a special
  ) do
    in_kata do
      
      runner.stub_run({
        outcome: 'red',
        created: {'outcome.special' => content('Hello')}
      })
      post_run_tests # 1==ran-tests
      events = kata.events      
      assert_equal 2, kata.events.size
      assert_equal 'red_special', events[1]['colour']
      
      runner.stub_run({outcome: 'green'})
      post_run_tests # 2==ran-tests
      events = kata.events      
      assert_equal 3, kata.events.size
      assert_equal 'green', events[2]['colour']

      post_json '/kata/auto_revert', {
        id: @id,
        tab_seq: next_tab_seq
      }
      assert last_response.successful?

      events = kata.events
      assert_equal 4, kata.events.size
      event = kata.event(3)
      expected = [@id, 1]
      assert_equal expected, event['revert']
      assert_equal 'red_special', event['colour']
      assert_equal 'red_special', json['light']['colour']
    end
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - - -

  test '81F278', %w(
  | in individual kata, revert back to our own previous traffic-light
  | when there are multiple file-events to skip over before you
  | get to the previous traffic-light
  ) do
    in_kata do
      runner.stub_run({outcome: 'green'})
      post_run_tests # 1==ran-tests
      assert_equal 2, kata.events.size, kata.events

      filename = 'newfile.txt'
      post_json '/kata/file_create', {
        id: @id,
        tab_seq: next_tab_seq,
        data: { file_content: @files },
        filename: filename
      }
      assert last_response.successful?
      assert_equal 3, kata.events.size, kata.events
      @files[filename] = ''

      post_json '/kata/file_delete', {
        id: @id,
        tab_seq: next_tab_seq,
        data: { file_content: @files },
        filename: filename
      }
      assert last_response.successful?
      assert_equal 4, kata.events.size, kata.events

      # REVERT
      post_json '/kata/auto_revert', {
        id: @id,
        tab_seq: next_tab_seq
      }
      assert last_response.successful?
      assert_equal 5, kata.events.size
      event = kata.event(4)
      expected = [@id, 1]
      assert_equal expected, event['revert']
      assert_equal 'green', event['colour']
      assert_equal 'green', json['light']['colour']
    end
  end

end
