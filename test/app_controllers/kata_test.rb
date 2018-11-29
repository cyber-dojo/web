require_relative 'app_controller_test_base'

class KataControllerTest  < AppControllerTestBase

  def self.hex_prefix
    'BE8'
  end

  def hex_setup
    set_runner_class('RunnerService')
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  test '76E', %w( run_tests with bad kata id raises ) do
    error = assert_raises(StandardError) {
      run_tests({ 'id' => 'bad' })
    }
    assert_equal 'invalid kata_id', error.message
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  # landing pages
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

  def starter_manifest
    manifest = starter.language_manifest(default_display_name, default_exercise_name)
    manifest['created'] = time_now
    manifest
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  # traffic-lights
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
      run_tests({ 'max_seconds' => 3 })
      assert_equal :timed_out, kata.lights[-1].colour
    }
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  test '223', %w( red-green-amber ) do
    in_kata { |kata|
      run_tests
      assert_equal :red, kata.lights[-1].colour

      sub_file('hiker.rb', '6 * 9', '6 * 7')
      run_tests
      assert_equal :green, kata.lights[-1].colour

      change_file('hiker.rb', 'syntax-error')
      run_tests
      assert_equal :amber, kata.lights[-1].colour
    }
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  # Batch-Method
  #- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  class SaverDummy
    def kata_ran_tests(_id, _index, _files, _now, _duration, _stdout, _stderr, _status, _colour)
    end
  end

  test 'B29', %w(
  the browser caches all the run_test parameters
  to ensure run_tests() only issues a
  single saver command to save the test-run result ) do
    in_kata { |kata|
      params = {
        :format => :js,
        :id => kata.id,
        :image_name => kata.manifest.image_name,
        :hidden_filenames => JSON.unparse([]),
        :max_seconds => kata.manifest.max_seconds
      }
      # TODO: not enough. Need to set the ENV-VAR so
      # storer is set in new controller thread
      @saver = SaverDummy.new
      begin
        post '/kata/run_tests', params:params.merge(@params_maker.params)
      ensure
        @saver = nil
      end
    }
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  # round-tripping
  #- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  test '9DC', %w( round-tripping:
  when a test-event deletes an existing text file
  then the storer records it
  ) do
    in_kata { |kata|
      filename = 'readme.txt'
      change_file('cyber-dojo.sh', "rm #{filename}")
      run_tests
      filenames = kata.files.keys.sort
      refute filenames.include?(filename), filenames
    }
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  test '9DD', %w( round-tripping:
  when a test-event creates a new text file
  then the storer records it
  ) do
    in_kata { |kata|
      filename = 'wibble.txt'
      change_file('cyber-dojo.sh', "echo Hello > #{filename}")
      run_tests
      filenames = kata.files.keys.sort
      assert filenames.include?(filename), filenames
      assert_equal "Hello\n", kata.files[filename]
    }
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  test '9DE', %w( round-tripping:
  when a test-event changes a text-file
  then the storer records it ) do
    in_kata { |kata|
      filename = 'readme.txt'
      change_file('cyber-dojo.sh', "echo Hello > #{filename}")
      run_tests
      filenames = kata.files.keys.sort
      assert filenames.include?(filename), filenames
      assert_equal "Hello\n", kata.files[filename]
    }
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  test '9DF', %w( round-tripping:
  when a test-event creates a new text file called output
  then the storer does _not_ record it because it already records
  stdout+stderr as output
  ) do
    in_kata { |kata|
      filename = 'output'
      script = kata.files['cyber-dojo.sh']
      script += "\necho Hello > #{filename}"
      change_file('cyber-dojo.sh', script)
      run_tests
      filenames = kata.files.keys.sort
      assert filenames.include?(filename), filenames
      expected = [
        '  1) Failure:',
        'TestHiker#test_life_the_universe_and_everything [test_hiker.rb:7]:',
        'Expected: 42',
        '  Actual: 54'
      ].join("\n")
      actual = kata.files['stdout']
      assert actual.include?(expected), actual
    }
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  # hidden_filenames
  #- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  test 'A28', %w( round-tripping:
  hidden files are not visible
  ) do
    in_kata { |kata|
      run_tests
      filenames = kata.files.keys.sort
      expected = %w(
        coverage.rb
        cyber-dojo.sh
        hiker.rb
        readme.txt
        status
        stdout
        stderr
        test_hiker.rb
      )
      # coverage/.resultset.json has been removed
      # coverage/.last_run.json has been removed
      assert_equal expected.sort, filenames.sort
    }
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  # show-json for Atom editor plug-in
  #- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  test 'B75', %w(
  show-json which is used in an Atom plugin ) do
    set_runner_class('RunnerStub')
    in_kata { |kata|
      run_tests
      params = { :format => :json, :id => kata.id, :avatar => avatar.name }
      get '/kata/show_json', params:params
    }
  end

end
