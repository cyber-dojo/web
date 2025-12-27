require_relative 'app_controller_test_base'
require_relative 'capture_stdout_stderr'

class MobbingOutOfSyncTest  < AppControllerTestBase

  include CaptureStdoutStderr

  def self.hex_prefix
    'zW7'
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  test 'B30', %w(
  given two (or more) laptops as the same avatar
  and one has not synced (by hitting refresh in their browser)
  and so their current traffic-light-index lags behind
  when they run their tests
  then it is a 200 (and not a 500)
  but no extra saver event is created.
  ) do
    in_kata do |kata|
      post_run_tests
      assert_equal 2, @index

      post_run_tests
      assert_equal 3, @index

      stdout,stderr = capture_stdout_stderr {
        post_run_tests({'index' => 2})
      }
      assert_equal 3, @index
      assert_equal '', stderr
      assert stdout.include?('"message": "Out of order event"')
    end
  end

end
