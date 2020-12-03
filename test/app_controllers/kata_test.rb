require_relative 'app_controller_test_base'
require_relative 'capture_stdout_stderr'

class KataControllerTest  < AppControllerTestBase

  include CaptureStdoutStderr

  def self.hex_prefix
    'BE8'
  end

  def hex_setup
    set_runner_class('RunnerService')
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  test '9B9', %w( edit landing page ) do
    in_kata do |kata|
      get "/kata/edit/#{kata.id}"
      assert_response :success
    end
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  test '221', %w( timed_out ) do
    in_kata do |kata|
      change_file('hiker.sh',
        <<~BASH_CODE
        answer()
        {
          while true; do
            :
          done
        }
        BASH_CODE
      )
      post_run_tests({ 'max_seconds' => 3 })
      assert_equal :timed_out, kata.lights[-1].colour
    end
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  test '223', %w( red-green-amber ) do
    in_kata do |kata|
      post_run_tests
      assert_equal :red, kata.lights[-1].colour
      sub_file('hiker.sh', '6 * 9', '6 * 7')
      post_run_tests
      assert_equal :green, kata.lights[-1].colour
      change_file('hiker.sh', 'syntax-error')
      post_run_tests
      assert_equal :amber, kata.lights[-1].colour
    end
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  test 'c25', %w(
  when [test] button is pressed
  the model-http-service is now used and not the saver-http-service
  ) do
    set_runner_class('RunnerStub')
    in_kata do
      set_saver_class('SaverExceptionRaiser')
      post_run_tests
      assert_response :success
    end
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  test '76E', %w( run_tests with bad ID is a 500 ) do
    in_kata do |kata|
      post '/kata/run_tests', params:run_test_params({ 'id' => 'bad' })
      assert_response 500
    end
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
        'image_name' => kata.manifest.image_name,
        'file_content' => plain(kata.files),
        'max_seconds' => kata.manifest.max_seconds,
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

  #- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  test '9DC', %w(
  when a test-event deletes an existing text file
  then the saver records it
  ) do
    filename = 'readme.txt'
    id = in_kata do |kata|
      id = kata.id
      assert kata.files.keys.include?(filename)
      change_file('cyber-dojo.sh', "rm #{filename}")
      post_run_tests
      kata.id
    end
    kata = katas[id]
    files = kata.files
    filenames = files.keys.sort
    refute filenames.include?(filename), filenames
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  test '9DD', %w(
  when a test-event creates a new text file
  then the saver records it
  ) do
    filename = 'wibble.txt'
    id = in_kata do |kata|
      change_file('cyber-dojo.sh', "echo -n Hello > #{filename}")
      post_run_tests
      kata.id
    end
    kata = katas[id]
    files = kata.files
    filenames = files.keys.sort
    assert filenames.include?(filename), filenames
    assert_equal 'Hello', files[filename]['content']
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  test '9DE', %w(
  when a test-event changes a regular text-file
  then the saver records it ) do
    filename = 'readme.txt'
    id = in_kata do |kata|
      assert kata.files.keys.include?(filename)
      change_file('cyber-dojo.sh', "echo -n Hello > #{filename}")
      post_run_tests
      kata.id
    end
    kata = katas[id]
    files = kata.files
    filenames = files.keys.sort
    assert filenames.include?(filename), filenames
    assert_equal 'Hello', files[filename]['content']
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  test '736', %w(
  when cyber-dojo.sh creates a new text file called stdout
  then the saver records it separately to the stdout 'output' file
  ) do
    in_kata do |kata|
      script = [
        "echo -n Hello",
        "echo -n Bonjour > stdout"
      ].join("\n")
      change_file('cyber-dojo.sh', script)
      post_run_tests

      assert kata.files.keys.include?('stdout')
      assert_equal 'Bonjour', kata.files['stdout']['content']

      assert_equal 'Hello', kata.stdout['content']
    end
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  test '737', %w(
  when cyber-dojo.sh creates a new text file called stderr
  then the saver records it separately to the stderr 'output' file
  ) do
    in_kata do |kata|
      script = [
        ">&2 echo -n Hello2",
        "echo -n Bonjour2 > stderr"
      ].join("\n")
      change_file('cyber-dojo.sh', script)
      post_run_tests

      assert kata.files.keys.include?('stderr')
      assert_equal 'Bonjour2', kata.files['stderr']['content']

      assert_equal 'Hello2', kata.stderr['content']
    end
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  test '738', %w(
  when a test-event creates a new text file called status
  then the saver does _not_ record it because it already records
  stdout,stderr,status as 'output' files
  ) do
    in_kata do |kata|
      script = [
        "echo -n Bonjour3 > status",
        "exit 42"
      ].join("\n")
      change_file('cyber-dojo.sh', script)
      post_run_tests

      assert kata.files.keys.include?('status')
      assert_equal 'Bonjour3', kata.files['status']['content']

      assert_equal '42', kata.status
    end
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  test 'A28', %w(
  generated files are returned from runner
  unless cyber-dojo.sh explicitly deletes them ) do
    generated_filename = 'xxxx.txt'
    id = in_kata do |kata|
      change_file('cyber-dojo.sh', "cat xxxx > #{generated_filename}")
      post_run_tests
      kata.id
    end
    kata = katas[id]
    light = kata.lights[-1]
    filenames = light.files.keys
    assert filenames.include?(generated_filename), filenames
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  test 'B77',
  %w( set_colour() persists the colour option ) do
    in_kata do |kata|
      post '/kata/set_colour', params:{ id:kata.id, value:'off' }
      assert_equal 'off', kata.colour
      post '/kata/set_colour', params:{ id:kata.id, value:'on' }
      assert_equal 'on', kata.colour
    end
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  test 'B78',
  %w( set_theme() persists the theme option ) do
    in_kata do |kata|
      post '/kata/set_theme', params:{ id:kata.id, value:'light' }
      assert_equal 'light', kata.theme
      post '/kata/set_theme', params:{ id:kata.id, value:'dark' }
      assert_equal 'dark', kata.theme
    end
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  test 'B79',
  %w( set_predict() persists the predict option ) do
    in_kata do |kata|
      post '/kata/set_predict', params:{ id:kata.id, value:'on' }
      assert_equal 'on', kata.predict
      post '/kata/set_predict', params:{ id:kata.id, value:'off' }
      assert_equal 'off', kata.predict
    end
  end

end
