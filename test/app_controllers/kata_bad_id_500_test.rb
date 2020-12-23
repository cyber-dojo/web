require_relative 'app_controller_test_base'
require_relative 'capture_stdout_stderr'

class KataControllerTest  < AppControllerTestBase

  include CaptureStdoutStderr

  def self.hex_prefix
    'BE8'
  end

  test '76E', %w( run_tests with bad ID is a 500 ) do
    set_runner_class('RunnerService')
    in_kata do |kata|
      capture_stdout_stderr {
        post '/kata/run_tests', params:run_test_params({ 'id' => 'bad' })
      }
      assert_response 500
    end
  end

end
