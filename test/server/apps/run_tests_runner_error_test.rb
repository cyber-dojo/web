require_relative 'apps_test_base'
require_relative 'runner_run_raises_stub'

class RunTestsRunnerErrorTest < AppsTestBase

  test 'Qm7a01', %w(
  | a [test] whose runner call raises a RunnerService::Error answers 500.
  | The response body is the error's message, which the [test] dialog shows.
  ) do
    in_kata do
      externals.instance_exec { @runner = RunnerRunRaisesStub.new(self) }
      post_run_tests_failing_write
      assert_equal 500, last_response.status
      assert_equal RunnerRunRaisesStub::MESSAGE, last_response.body
    end
  end

end
