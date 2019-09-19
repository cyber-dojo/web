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
    group = groups.new_group(starter_manifest)
    get "/kata/group/#{group.id}"
    assert_response :success
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  test '9B9', %w( edit landing page ) do
    kata = katas.new_kata(starter_manifest)
    get "/kata/edit/#{kata.id}"
    assert_response :success
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  test '76E', %w( run_tests with bad ID is 500 ) do
    in_kata { |kata|
      post '/kata/run_tests', params:run_test_params({ 'id' => 'bad' })
      assert_response 500
    }
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  test '221', %w( timed_out ) do
    in_kata { |kata|
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
    }
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  test '223', %w( red-green-amber ) do
    in_kata { |kata|
      post_run_tests
      assert_equal :red, kata.lights[-1].colour
      sub_file('hiker.rb', '6 * 9', '6 * 7')
      post_run_tests
      assert_equal :green, kata.lights[-1].colour
      change_file('hiker.rb', 'syntax-error')
      post_run_tests
      assert_equal :amber, kata.lights[-1].colour
    }
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  test 'c24', %w(
  Raggerservice::Error gracefully degrades [test] to 'faulty' colour
  ) do
    set_runner_class('RunnerStub')
    set_ragger_class('RaggerExceptionRaiser')
    in_kata { |kata|
      post_run_tests
      assert_equal :faulty, kata.lights[-1].colour
    }
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  test 'c25', %w(
  SaverService::Error on already existing session
  gracefully degrades [test] to offline functionality
  ) do
    set_runner_class('RunnerStub')
    in_kata {
      set_saver_class('SaverExceptionRaiser')
      post_run_tests
      assert_response :success
    }
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

=begin TODO: saver now has a single call to get the manifest.
  test 'B29', %w(
  the browser caches all the run_test parameters
  to ensure run_tests() only issues a
  single command to saver which is to save the test-run result ) do
    in_kata { |kata|
      options = {
        'image_name' => kata.manifest.image_name,
        'id' => kata.id,
        'max_seconds' => kata.manifest.max_seconds,
        'hidden_filenames' => JSON.unparse(kata.manifest.hidden_filenames)
      }
      set_saver_class('SaverDummy')
      post_run_tests(options)
      filename = "/tmp/cyber-dojo-#{hex_test_kata_id}.json"
      lines = IO.read(filename).lines
      assert_equal 1, lines.size
      assert lines[0].start_with?('["kata_ran_tests"')
    }
  end
=end

  #- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  test '9DC', %w(
  when a test-event deletes an existing text file
  then the saver records it
  ) do
    in_kata { |kata|
      filename = 'readme.txt'
      assert kata.files.keys.include?(filename)
      change_file('cyber-dojo.sh', "rm #{filename}")
      post_run_tests
      filenames = kata.files.keys.sort
      refute filenames.include?(filename), filenames
    }
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  test '9DD', %w(
  when a test-event creates a new text file
  then the saver records it
  ) do
    in_kata { |kata|
      filename = 'wibble.txt'
      change_file('cyber-dojo.sh', "echo -n Hello > #{filename}")
      post_run_tests
      filenames = kata.files.keys.sort
      assert filenames.include?(filename), filenames
      assert_equal 'Hello', kata.files[filename]['content']
    }
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  test '9DE', %w(
  when a test-event changes a regular text-file
  then the saver records it ) do
    in_kata { |kata|
      filename = 'readme.txt'
      assert kata.files.keys.include?(filename)
      change_file('cyber-dojo.sh', "echo -n Hello > #{filename}")
      post_run_tests
      filenames = kata.files.keys.sort
      assert filenames.include?(filename), filenames
      assert_equal 'Hello', kata.files[filename]['content']
    }
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  test '736', %w(
  when a test-event creates a new text file called stdout
  then the saver does _not_ record it because it already records
  stdout,stderr,status as 'output' files
  ) do
    in_kata { |kata|
      filename = 'stdout'
      script = kata.files['cyber-dojo.sh']['content']
      script += "\necho -n Hello > #{filename}"
      change_file('cyber-dojo.sh', script)
      post_run_tests
      filenames = kata.files.keys.sort
      refute filenames.include?(filename), filenames
      expected = [
        '  1) Failure:',
        'TestHiker#test_life_the_universe_and_everything [test_hiker.rb:8]:',
        'Expected: 42',
        '  Actual: 54'
      ].join("\n")
      actual = kata.lights[-1].stdout['content']
      assert actual.include?(expected), actual
    }
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  test '737', %w(
  when a test-event creates a new text file called stderr
  then the saver does _not_ record it because it already records
  stdout,stderr,status as 'output' files
  ) do
    in_kata { |kata|
      filename = 'stderr'
      script = kata.files['cyber-dojo.sh']['content']
      script += "\necho -n Hello > #{filename}"
      change_file('cyber-dojo.sh', script)
      post_run_tests
      filenames = kata.files.keys.sort
      refute filenames.include?(filename), filenames
      assert_equal '', kata.lights[-1].stderr['content']
    }
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  test '738', %w(
  when a test-event creates a new text file called status
  then the saver does _not_ record it because it already records
  stdout,stderr,status as 'output' files
  ) do
    in_kata { |kata|
      filename = 'status'
      script = kata.files['cyber-dojo.sh']['content']
      script += "\necho -n Hello > #{filename}"
      change_file('cyber-dojo.sh', script)
      post_run_tests
      filenames = kata.files.keys.sort
      refute filenames.include?(filename), filenames
      assert_equal 0, kata.lights[-1].status
    }
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  test 'A28',
  %w( generated files that match hidden files are stripped away ) do
    in_kata { |kata|
      filenames = %w(
        coverage.rb
        cyber-dojo.sh
        hiker.rb
        readme.txt
        test_hiker.rb
      )
      assert_equal filenames.sort, kata.files.keys.sort
      script = kata.files['cyber-dojo.sh']['content']
      script += "\nls -al coverage"
      change_file('cyber-dojo.sh', script)
      post_run_tests
      light = kata.lights[-1]
      stdout = light.stdout['content']
      assert stdout.include?('.resultset.json'), stdout
      assert_equal filenames.sort, light.files.keys.sort
    }
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  test 'B75',
  %w( show-json which is used in an Atom plugin ) do
    in_kata { |kata|
      post_run_tests
      get '/kata/show_json', params:{ :format => :json, :id => kata.id }
      assert_response :success
    }
  end

end
