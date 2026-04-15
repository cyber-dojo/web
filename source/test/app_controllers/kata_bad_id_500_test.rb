require_relative 'app_controller_test_base'
require_relative 'capture_stdout_stderr'

class KataControllerTest  < AppControllerTestBase

  include CaptureStdoutStderr

  test 'BE876E', %w(
  | run_tests with bad ID is a 200 because SaverExceptions are swallowed
  ) do
    in_kata do |kata|
      stdout,stderr = capture_stdout_stderr do
        post_run_tests(id: 'bad')
      end
      assert_equal '', stderr        
      assert stdout.include?('no implicit conversion of String into Integer')
      assert_equal 200, last_response.status
    end
  end

end
