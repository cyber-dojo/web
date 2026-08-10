require_relative 'apps_test_base'
require_relative '../../capture_stdout_stderr'
require_relative 'spooler_ran_tests_raises_stub'

class RunTestsSaveErrorTest < AppsTestBase

  include CaptureStdoutStderr

  test 'c2vE41', %w(
  | when [test] runs but the spooler write fails with a transient error (a
  | spooler outage), the response still returns the runner's traffic-light and is
  | a 200, and commits no event. The light is a runner fact, independent of the
  | write landing.
  ) do
    in_kata do |kata|
      externals.instance_exec { @spooler = SpoolerRanTestsRaisesStub.new(self) }
      stdout, stderr = capture_stdout_stderr {
        post_run_tests_failing_write
      }
      assert last_response.ok?, last_response.body
      assert_equal 1, saver.kata_events(kata.id).size,
        'a failed write must not commit an event'
      assert_equal '', stderr
      assert stdout.include?('spooler unavailable'), stdout
    end
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - - -

  test 'c2vE42', %w(
  | when [test] runs with a prediction matching the outcome, so the write
  | goes to kata_predicted_right, and that write fails with a transient
  | error, the response still returns the light and commits no event
  ) do
    in_kata do |kata|
      runner.stub_run({outcome: 'green'})
      externals.instance_exec { @spooler = SpoolerRanTestsRaisesStub.new(self) }
      stdout, stderr = capture_stdout_stderr {
        post_run_tests_failing_write(predicted: 'green')
      }
      assert last_response.ok?, last_response.body
      assert_equal 'green', json['light']['colour']
      assert_equal 'green', json['light']['predicted']
      assert_equal 1, saver.kata_events(kata.id).size,
        'a failed write must not commit an event'
      assert_equal '', stderr
      assert stdout.include?('spooler unavailable'), stdout
    end
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - - -

  test 'c2vE43', %w(
  | when [test] runs with a prediction not matching the outcome, so the
  | write goes to kata_predicted_wrong, and that write fails with a
  | transient error, the response still returns the light and commits no event
  ) do
    in_kata do |kata|
      runner.stub_run({outcome: 'green'})
      externals.instance_exec { @spooler = SpoolerRanTestsRaisesStub.new(self) }
      stdout, stderr = capture_stdout_stderr {
        post_run_tests_failing_write(predicted: 'red')
      }
      assert last_response.ok?, last_response.body
      assert_equal 'green', json['light']['colour']
      assert_equal 'red', json['light']['predicted']
      assert_equal 1, saver.kata_events(kata.id).size,
        'a failed write must not commit an event'
      assert_equal '', stderr
      assert stdout.include?('spooler unavailable'), stdout
    end
  end

end
