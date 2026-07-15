require_relative 'app_controller_test_base'
require_relative 'capture_stdout_stderr'

class MobbingOutOfSyncTest  < AppControllerTestBase

  include CaptureStdoutStderr

  test 'zW7B30', %w(
  | given two laptops as the same avatar (two different laptop_ids)
  | and one has not synced (by hitting refresh in their browser)
  | and so its current traffic-light-index lags behind the committed head
  | when it runs its tests
  | then genuine mobbing is detected: it is a 200 (and not a 500)
  | the response is flagged out-of-sync (the mobbing dialog)
  | and no extra saver event is created (the interfering write is not saved).
  ) do
    in_kata do |kata|
      # Laptop A: synced at the fresh kata (holding index 1), runs its tests
      # and commits the event at index 1.
      post_run_tests(index: 1)
      assert_equal 2, @index
      assert_equal 1, saver.kata_events(kata.id).last['index']

      # Laptop B: a different browser (fresh cookies, so a different laptop_id),
      # same avatar, that loaded when the kata was fresh and has NOT synced since,
      # so it still holds the stale index 1. Its [test] therefore lands behind the
      # head, over an event written by ANOTHER laptop - genuine mobbing.
      clear_cookies
      stdout, stderr = capture_stdout_stderr {
        post_run_tests(index: 1)
      }
      assert last_response.ok?, last_response.body   # 200, not 500
      assert json['out_of_sync'], json               # the mobbing dialog
      assert_equal 1, saver.kata_events(kata.id).last['index'],
        'the interfering write must not be saved'
      assert_equal '', stderr
      assert stdout.include?("Out of order event for #{kata.id}"), stdout
    end
  end

end
