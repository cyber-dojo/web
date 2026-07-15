require_relative 'app_controller_test_base'
require_relative 'capture_stdout_stderr'
require_relative 'saver_ran_tests_raises_stub'

class RunTestsSaveErrorTest < AppControllerTestBase

  include CaptureStdoutStderr

  test 'c2vE41', %w(
  | when [test] runs but the saver save fails with a NON-out-of-order error
  | (a transient saver outage, not mobbing), the response returns the runner's
  | traffic-light and is a 200, is NOT flagged out-of-sync, commits no event,
  | and signals saved:false so the browser does NOT advance its index. Advancing
  | on a non-committing save is what later sends an ahead index and shows a
  | false mobbing dialog.
  ) do
    in_kata do |kata|
      set_class('saver', 'SaverRanTestsRaisesStub')
      stdout, stderr = capture_stdout_stderr {
        post_run_tests(index: 1)
      }
      assert last_response.ok?, last_response.body
      refute json['out_of_sync'], json
      assert_equal 1, saver.kata_events(kata.id).size,
        'a failed save must not commit an event'
      assert_equal false, json['saved'], json
      assert_equal '', stderr
      assert stdout.include?('saver unavailable'), stdout
    end
  end

end
