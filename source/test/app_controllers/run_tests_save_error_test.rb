require_relative 'app_controller_test_base'
require_relative 'capture_stdout_stderr'
require_relative 'spooler_ran_tests_raises_stub'

class RunTestsSaveErrorTest < AppControllerTestBase

  include CaptureStdoutStderr

  test 'c2vE41', %w(
  | when [test] runs but the spooler write fails with a transient error (a
  | spooler outage), the response still returns the runner's traffic-light and is
  | a 200, and commits no event. The light is a runner fact, independent of the
  | write landing.
  ) do
    in_kata do |kata|
      set_class('spooler', 'SpoolerRanTestsRaisesStub')
      stdout, stderr = capture_stdout_stderr {
        post_run_tests
      }
      assert last_response.ok?, last_response.body
      assert_equal 1, saver.kata_events(kata.id).size,
        'a failed write must not commit an event'
      assert_equal '', stderr
      assert stdout.include?('spooler unavailable'), stdout
    end
  end

end
