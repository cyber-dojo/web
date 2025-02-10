require_relative 'app_controller_test_base'
require_relative 'capture_stdout_stderr'

class KataControllerTest  < AppControllerTestBase

  include CaptureStdoutStderr

  def self.hex_prefix
    'BE8'
  end

  test '76E', %w( run_tests with bad ID is a 200 because SaverExceptions are swallowed ) do
    set_runner_class('RunnerService')
    in_kata do |kata|
      stdout,stderr = capture_stdout_stderr do
        post '/kata/run_tests', params:run_test_params({ 'id' => 'bad' })
      end
      assert_equal '', stderr
      assert stdout.include?('no implicit conversion of String into Integer')
      assert_response 200
    end
  end

end
