require_relative 'app_controller_test_base'

class KataControllerTest  < AppControllerTestBase

  def self.hex_prefix
    'BE8'
  end

  def hex_setup
    set_runner_class('RunnerService')
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  test '9B8', %w( group landing page ) do
    in_group do |group|
      get "/kata/group/#{group.id}"
      assert_response :success
    end
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  test '9B9', %w( edit landing page ) do
    in_kata do |kata|
      get "/kata/edit/#{kata.id}"
      assert_response :success
    end
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  test '76E', %w( run_tests with bad ID is 500 ) do
    in_kata do |kata|
      post '/kata/run_tests', params:run_test_params({ 'id' => 'bad' })
      assert_response 500
    end
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  test '221', %w( timed_out ) do
    in_kata do |kata|
      change_file('hiker.rb',
        <<~RUBY_CODE
        def answer
          while true
          end
        end
        RUBY_CODE
      )
      post_run_tests({ 'max_seconds' => 3 })
      assert_equal :timed_out, kata.lights[-1].colour
    end
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  test '223', %w( red-green-amber ) do
    set_ragger_class('RaggerService')
    in_kata do |kata|
      post_run_tests
      assert_equal :red, kata.lights[-1].colour
      sub_file('hiker.rb', '6 * 9', '6 * 7')
      post_run_tests
      assert_equal :green, kata.lights[-1].colour
      change_file('hiker.rb', 'syntax-error')
      post_run_tests
      assert_equal :amber, kata.lights[-1].colour
    end
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  test 'c24', %w(
  Raggerservice::Error gracefully degrades [test] to 'faulty' colour
  ) do
    set_runner_class('RunnerStub')
    set_ragger_class('RaggerExceptionRaiser')
    in_kata do |kata|
      post_run_tests
      assert_equal :faulty, kata.lights[-1].colour
    end
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  test 'c25', %w(
  SaverService::Error on already existing session
  gracefully degrades [test] to offline functionality
  ) do
    set_runner_class('RunnerStub')
    in_kata do
      set_saver_class('SaverExceptionRaiser')
      post_run_tests
      assert_response :success
    end
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  test 'B29', %w(
  the browser caches all the run_test parameters
  to ensure run_tests() only issues a
  single command to the saver service
  ) do
    in_kata do |kata|
      params = {
        'format' => 'js',
        'version' => kata.schema.version,
        'id' => kata.id,
        'index' => 1,
        'image_name' => kata.manifest.image_name,
        'file_content' => plain(kata.files),
        'max_seconds' => kata.manifest.max_seconds,
        'hidden_filenames' => JSON.unparse(kata.manifest.hidden_filenames),
      }
      count_before = saver.log.size
      post '/kata/run_tests', params:params
      assert_response :success
      count_after = saver.log.size
      assert_equal 1, count_after-count_before, saver.log
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
  when a test-event creates a new text file called stdout
  then the saver does _not_ record it because it already records
  stdout,stderr,status as 'output' files
  ) do
    filename = 'stdout'
    id = in_kata do |kata|
      script = kata.files['cyber-dojo.sh']['content']
      script += "\necho -n Hello > #{filename}"
      change_file('cyber-dojo.sh', script)
      post_run_tests
      kata.id
    end
    kata = katas[id]
    files = kata.files
    filenames = files.keys.sort
    refute filenames.include?(filename), filenames
    expected = [
      '  1) Failure:',
      'TestHiker#test_life_the_universe_and_everything [test_hiker.rb:8]:',
      'Expected: 42',
      '  Actual: 54'
    ].join("\n")
    actual = kata.lights[-1].stdout['content']
    assert actual.include?(expected), actual
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  test '737', %w(
  when a test-event creates a new text file called stderr
  then the saver does _not_ record it because it already records
  stdout,stderr,status as 'output' files
  ) do
    filename = 'stderr'
    id = in_kata do |kata|
      script = kata.files['cyber-dojo.sh']['content']
      script += "\necho -n Hello > #{filename}"
      change_file('cyber-dojo.sh', script)
      post_run_tests
      kata.id
    end
    kata = katas[id]
    filenames = kata.files.keys.sort
    refute filenames.include?(filename), filenames
    assert_equal '', kata.lights[-1].stderr['content']
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  test '738', %w(
  when a test-event creates a new text file called status
  then the saver does _not_ record it because it already records
  stdout,stderr,status as 'output' files
  ) do
    filename = 'status'
    id = in_kata do |kata|
      script = kata.files['cyber-dojo.sh']['content']
      script += "\necho -n Hello > #{filename}"
      change_file('cyber-dojo.sh', script)
      post_run_tests
      kata.id
    end
    kata = katas[id]
    filenames = kata.files.keys.sort
    refute filenames.include?(filename), filenames
    assert_equal 0, kata.lights[-1].status
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  test 'A28',
  %w( generated files that match hidden files are stripped away ) do
    filenames = %w(
      coverage.rb
      cyber-dojo.sh
      hiker.rb
      readme.txt
      test_hiker.rb
    )
    id = in_kata do |kata|
      assert_equal filenames.sort, kata.files.keys.sort
      script = kata.files['cyber-dojo.sh']['content']
      script += "\nls -al coverage"
      change_file('cyber-dojo.sh', script)
      post_run_tests
      kata.id
    end
    kata = katas[id]
    light = kata.lights[-1]
    stdout = light.stdout['content']
    assert stdout.include?('.resultset.json'), stdout
    assert_equal filenames.sort, light.files.keys.sort
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  test 'B75',
  %w( show-json which is used in an Atom plugin ) do
    in_kata do |kata|
      post_run_tests
      get '/kata/show_json', params:{ :format => :json, :id => kata.id }
      assert_response :success
    end
  end

end
