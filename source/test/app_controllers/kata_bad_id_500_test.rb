require_relative 'app_controller_test_base'
require_relative 'capture_stdout_stderr'

class KataControllerTest  < AppControllerTestBase

  include CaptureStdoutStderr

  test 'BE876E', %w(
  | run_tests with a bad kata id still returns 200 with the runner's light. The
  | light is a runner fact and web POSTs the write to the spooler without gating
  | on it, so no write error surfaces at web - the spooler accepts the intake and
  | the doomed write fails later at the drainer, invisibly to web.
  ) do
    in_kata do |kata|
      _stdout, stderr = capture_stdout_stderr do
        post_run_tests(id: 'bad')
      end
      assert_equal '', stderr, :stderr
      assert_equal 200, last_response.status, :status
    end
  end

end
