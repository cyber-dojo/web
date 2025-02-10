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
  and information is logged to stdout.
  ) do
    set_runner_class('RunnerStub')
    in_kata do |kata|
      params = {
        'format' => 'js',
        'id' => kata.id,
        'image_name' => kata.manifest['image_name'],
        'file_content' => plain(kata.event(-1)['files']),
        'max_seconds' => kata.manifest['max_seconds'],
      }
      params['index'] = 1
      post '/kata/run_tests', params:params
      assert_response :success

      params['index'] = 2
      post '/kata/run_tests', params:params
      assert_response :success

      params['index'] = 3
      post '/kata/run_tests', params:params
      assert_response :success

      params['index'] = 1 # lagging
      stdout,stderr = capture_stdout_stderr {
        post '/kata/run_tests', params:params
      }
      assert_equal '', stderr
      refute_equal '', stdout
      assert_response :success
    end
  end

end
