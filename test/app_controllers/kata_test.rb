require_relative 'app_controller_test_base'

class KataControllerTest  < AppControllerTestBase

  def self.hex_prefix
    'BE83BC'
  end

  def hex_setup
    set_runner_class('RunnerService')
  end

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

  test '76E', %w( run_tests with bad kata id raises ) do
    error = assert_raises(StandardError) {
      run_tests({ 'id' => 'bad' })
    }
    assert_equal 'invalid kata_id', error.message
  end

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

  test '223', %w( red ) do
    in_kata(:stateless) {
      as_avatar {
        run_tests
        assert_equal :red, avatar.lights[-1].colour
      }
    }
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  test '224', %w( amber ) do
    in_kata(:stateful) {
      as_avatar {
        change_file('hiker.rb', 'syntax-error')
        run_tests
        assert_equal :amber, avatar.lights[-1].colour
      }
    }
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  test '225', %w( green ) do
    in_kata(:stateless) {
      as_avatar {
        sub_file('hiker.rb', '6 * 9', '6 * 7')
        run_tests
        assert_equal :green, avatar.lights[-1].colour
      }
    }
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  class StorerDummy
    def avatar_ran_tests(_kata_id, _avatar_name, _files, _now, _output, _colour)
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

  test '9DC', %w(
  a deleted file stays deleted in the next run
  for stateful runner_choice ) do
    in_kata(:stateful) {
      as_avatar {
        filename = 'instructions'
        ls_all = 'ls -al'
        delete_file(filename)
        run_tests
        change_file('cyber-dojo.sh', 'ls -al')
        run_tests
        output = avatar.visible_files['output']
        refute output.include?(filename), output
      }
    }
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  test '569', %w(
   when cyber-dojo.sh creates a file
   then it disappears on the next run
   for stateless runner_choice ) do
    in_kata(:stateless) {
      as_avatar {
        filename = 'wibble.txt'
        ls_all = 'ls -al'
        create_file = "touch #{filename} && #{ls_all}"
        change_file('cyber-dojo.sh', create_file)
        run_tests
        output = avatar.visible_files['output']
        assert output.include?(filename), output

        change_file('cyber-dojo.sh', ls_all)
        run_tests
        output = avatar.visible_files['output']
        refute output.include?(filename), output
      }
    }
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  test '3FD', %w(
  run_tests with bad image_name raises
  and does not cause resurrection ) do
    in_kata(:stateful) {
      as_avatar {
        error = assert_raises(StandardError) {
          run_tests({ 'image_name' => 'does_not/exist' })
        }
        assert error.message.start_with?('RunnerService:run_cyber_dojo_sh')
      }
    }
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  test '555', %w(
  run_tests for an old avatar seamlessly resurrects ) do
    in_kata(:stateful) {
      as_avatar {
        run_tests # 1
        assert_equal :red, avatar.lights[-1].colour
        output = avatar.visible_files['output']

        [ 'expected: 42', '     got: 54' ].each do |expected|
          assert output.include?(expected), output
        end

        # force avatar to end
        runner.avatar_old(kata.image_name, kata.id, avatar.name)

        # run_tests resurrects the avatar
        sub_file('hiker.rb', '6 * 9', '6 * 7')
        run_tests # 2
        expect = '1 example, 0 failures'
        assert avatar.visible_files['output'].include?(expect)
        assert_equal :green, avatar.lights[-1].colour
        diff = differ.diff(kata.id, avatar.name, was_tag=1, now_tag=2)

        assert diff['hiker.rb'].include?({
          'type' => 'deleted',
          'line' =>'  6 * 9',
          'number' => 2
        })

        assert diff['hiker.rb'].include?({
          'type' => 'added',
          'line' =>'  6 * 7',
          'number' => 2
        })
      }
    }
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  test 'E40', %w(
  run_tests for an old kata seamlessly resurrects ) do
    in_kata(:stateful) {
      as_avatar {
        run_tests # 1
        assert_equal :red, avatar.lights[-1].colour
        output = avatar.visible_files['output']

        [ 'expected: 42',
          '     got: 54'
        ].each do |expected|
          assert output.include?(expected), output
        end

        # force avatar and kata to end
        runner.avatar_old(kata.image_name, kata.id, avatar.name)
        runner.kata_old(kata.image_name, kata.id)

        # run_tests resurrects the kata & avatar
        sub_file('hiker.rb', '6 * 9', '6 * 7')
        run_tests # 2
        expect = '1 example, 0 failures'
        assert avatar.visible_files['output'].include?(expect)
        assert_equal :green, avatar.lights[-1].colour
        diff = differ.diff(kata.id, avatar.name, was_tag=1, now_tag=2)

        assert diff['hiker.rb'].include?({
          'type' => 'deleted',
          'line' =>'  6 * 9',
          'number' => 2
        })

        assert diff['hiker.rb'].include?({
          'type' => 'added',
          'line' =>'  6 * 7',
          'number' => 2
        })
      }
    }
  end

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

  #- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  def assert_file(filename, expected)
    assert_equal expected, avatar.visible_files[filename]
  end

end
