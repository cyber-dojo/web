require_relative 'app_controller_test_base'

class KataControllerTest  < AppControllerTestBase

  def self.hex_prefix
    'BE83BC'
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

  test '9B7', %w( individual landing page ) do
    in_kata(:stateless) {
      as_avatar {
        get "/kata/individual/#{kata.id}", params:{'avatar':avatar.name}
        assert_response :success
      }
    }
  end

  test '9B8', %w( group landing page ) do
    in_kata(:stateless) {
      get "/kata/group/#{kata.id}"
      assert_response :success
    }
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  test '9B9', %w( edit landing page ) do
    in_kata(:stateless) {
      as_avatar {
        get "/kata/edit/#{kata.id}", params:{'avatar':avatar.name}
        assert_response :success
      }
    }
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  # red/amber/green/timed_out
  #- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  test '221', %w( timed_out ) do
    in_kata(:stateless) {
      as_avatar {
        change_file('hiker.rb',
          <<~RUBY_CODE
          def answer
            while true
            end
          end
          RUBY_CODE
        )
        run_tests({ 'max_seconds' => 3 })
        assert_timed_out
      }
    }
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  test '223', %w( red-green-amber ) do
    in_kata(:stateless) {
      as_avatar {
        run_tests
        assert_equal :red, avatar.lights[-1].colour

        sub_file('hiker.rb', '6 * 9', '6 * 7')
        run_tests
        assert_equal :green, avatar.lights[-1].colour

        change_file('hiker.rb', 'syntax-error')
        run_tests
        assert_equal :amber, avatar.lights[-1].colour
      }
    }
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  # Batch-Method
  #- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  class StorerDummy
    def avatar_ran_tests(_kata_id, _avatar_name, _files, _now, _stdout, _stderr, _colour)
    end
  end

  test 'B29', %w(
  the browser caches all the run_test parameters
  to ensure run_tests() only issues a
  single storer command to save the test-run result ) do
    in_kata(:stateless) {
      as_avatar {
        params = {
          :format => :js,
          :id => kata.id,
          :runner_choice => kata.runner_choice,
          :image_name => kata.image_name,
          :avatar => avatar.name,
          :max_seconds => kata.max_seconds
        }
        @storer = StorerDummy.new
        begin
          post '/kata/run_tests', params:params.merge(@params_maker.params)
        ensure
          @storer = nil
        end
      }
    }
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  test '02D', %w(
  a new file persists for stateful runner_choice ) do
    in_kata(:stateful) {
      as_avatar {
        filename = 'hello.txt'
        new_file(filename, 'Hello world')
        run_tests
        change_file('cyber-dojo.sh', 'ls -al')
        run_tests
        output = avatar.visible_files['output']
        assert output.include?(filename), output
      }
    }
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  # round-tripping
  #- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  test '9DC', %w( round-tripping:
  when a test-event deletes an existing text file
  then the storer records it
  ) do
    in_kata(:stateless) {
      as_avatar {
        filename = 'instructions'
        change_file('cyber-dojo.sh', "rm #{filename}")
        run_tests
        filenames = avatar.visible_files.keys.sort
        refute filenames.include?(filename), filenames
      }
    }
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  test '9DD', %w( round-tripping:
  when a test-event creates a new text file
  then the storer records it
  ) do
    in_kata(:stateless) {
      as_avatar {
        filename = 'wibble.txt'
        change_file('cyber-dojo.sh', "echo Hello > #{filename}")
        run_tests
        filenames = avatar.visible_files.keys.sort
        assert filenames.include?(filename), filenames
        assert_equal "Hello\n", avatar.visible_files[filename]
      }
    }
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  test '9DE', %w( round-tripping:
  when a test-event creates a new text file called output
  then the storer does _not_ record it because it already records
  stdout+stderr as output
  ) do
    in_kata(:stateless) {
      as_avatar {
        filename = 'output'
        script = avatar.visible_files['cyber-dojo.sh']
        script += "\necho Hello > #{filename}"
        change_file('cyber-dojo.sh', script)
        run_tests
        filenames = avatar.visible_files.keys.sort
        assert filenames.include?(filename), filenames
        expected = [
          '  1) Failure:',
          'TestHiker#test_life_the_universe_and_everything [test_hiker.rb:6]:',
          'Expected: 42',
          '  Actual: 54'
        ].join("\n")
        actual = avatar.visible_files['output']
        assert actual.include?(expected), actual
      }
    }
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  # show-json for Atom editor plug-in
  #- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  test 'B75', %w(
  show-json which is used in an Atom plugin ) do
    set_runner_class('RunnerStub')
    in_kata(:stateful) {
      as_avatar {
        run_tests
        params = { :format => :json, :id => kata.id, :avatar => avatar.name }
        get '/kata/show_json', params:params
      }
    }
  end

  private # = = = = = = = = = = = = = = = =

  def assert_timed_out
    assert avatar.lights[-1].output.start_with?('Unable to complete')
    assert_equal :timed_out, avatar.lights[-1].colour
  end

end
