require_relative 'app_controller_test_base'

class KataControllerTest  < AppControllerTestBase

  def setup
    super
    @katas = Katas.new(self)
  end

  attr_reader :katas

  test 'BE876E',
  'run_tests with bad kata id raises' do
    params = {
      :format => :js,
      :id     => 'bad'
    }
    assert_raises(StandardError) {
      post 'kata/run_tests', params
    }
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  test 'BE8222',
  'run tests that times_out' do
    in_kata {
      kata_edit
      runner.stub_run(stdout='',stderr='',status='timed_out')
      run_tests
    }
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  test 'BE80F6',
  'edit and then run-tests' do
    in_kata {
      kata_edit
      run_tests
      change_file('hiker.h', 'syntax-error')
      run_tests
    }
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

=begin
  test 'BE8B29',
  'stateless run tests caches info so it only issues a single command to storer' do
    set_runner_class('RunnerService')
    set_storer_class('StorerFake') # add Call-Counts
    in_kata('stateless') { |kata_id|
      kata_edit
      params = {
        :format => :js,
        :id     => kata_id,
        :runner_choice => @kata.runner_choice,
        :image_name => 'cyberdojofoundation/python_unittest',
        :avatar => @avatar.name
      }.merge(@params_maker.params)
      post 'kata/run_tests', params

      # How to get @storer ???
      # ApplicationController does
      #   include Externals
      # which is a mixin and does
      #   def storer; @storer ||= external; end
      # Could I make externals an object in its own right
      # and somehow provide access to that?
      # Problem is that get/post calls are routed and
      # end up in a rails thread.
      # Could the test's hex-id become an ENV-VAR providing a key for a global hash?
      # Quite like that. And for a non-test the controller sees there is no
      # ENV-VAR and creates a uuidgen.
    }
  end
=end

  #- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  test 'BE87FD',
  'run_tests() on makefile with leading spaces',
  'are NOT converted to tabs and traffic-light is amber' do
    set_runner_class('RunnerService')
    in_kata {
      kata_edit
      run_tests
      assert_equal :red, @avatar.lights[-1].colour
      change_file(makefile, makefile_with_leading_spaces)
      run_tests
      assert_equal :amber, @avatar.lights[-1].colour
      assert_file makefile, makefile_with_leading_spaces
    }
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  test 'BE89DC',
  'when cyber-dojo.sh removes a file then it stays removed',
  'when RunnerService is stateful' do
    set_runner_class('RunnerService')
    in_kata {
      filename = 'fubar.txt'
      ls_all = 'ls -al'
      change_file('cyber-dojo.sh', "touch #{filename} && #{ls_all}")
      run_tests
      output = @avatar.visible_files['output']
      assert output.include?(filename), output

      change_file('cyber-dojo.sh', "rm -f #{filename} && #{ls_all}")
      run_tests
      output = @avatar.visible_files['output']
      refute output.include?(filename), output

      change_file('cyber-dojo.sh', ls_all)
      run_tests
      output = @avatar.visible_files['output']
      refute output.include?(filename), output
    }
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  test 'BE8569',
  'when cyber-dojo.sh creates a file then it disappears',
  'when RunnerService is stateless' do
    set_runner_class('RunnerService')
    in_kata('stateless') {
      filename = 'wibble.txt'
      ls_all = 'ls -al'
      create_file = "touch #{filename} && #{ls_all}"
      change_file('cyber-dojo.sh', create_file)
      run_tests
      output = @avatar.visible_files['output']
      assert output.include?(filename), output

      change_file('cyber-dojo.sh', ls_all)
      run_tests
      output = @avatar.visible_files['output']
      refute output.include?(filename), output
    }
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  test 'BE83FD',
  'run_tests with bad image_name raises and does not cause resurrection' do
    set_runner_class('RunnerService')
    in_kata { |kata_id|
      kata_edit
      params = {
        :format => :js,
        :id     => kata_id,
        :image_name => 'does_not/exist',
        :avatar => @avatar.name
      }
      assert_raises(StandardError) {
        post 'kata/run_tests', params.merge(@params_maker.params)
      }
    }
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  test 'BE8555',
  'avatar.test() for an old avatar seamlessly resurrects' do
    # Note: the kata-controller validates the kata-id and the avatar-name
    # (via the storer) so there is no path from the browser to
    # get runner.run to accept unvalidated arguments.
    set_runner_class('RunnerService')
    in_kata {
      run_tests # 1
      assert_equal :red, @avatar.lights[-1].colour
      output = @avatar.visible_files['output']

      [
        "makefile:14: recipe for target 'test.output' failed",
        'Assertion failed: answer() == 42 (hiker.tests.c: life_the_universe_and_everything: 7)',
        'make: *** [test.output] Aborted'
      ].each do |expected|
        assert output.include?(expected)
        # Note that depending on the host's OS, the last line might be
        #     make: *** [test.output] Aborted (core dumped)
        # viz with (core dumped) appended
      end

      runner.avatar_old(@kata.image_name, @kata.id, @avatar.name)

      change_file('hiker.c', content('hiker.c').sub('6 * 9', '6 * 7'))
      run_tests # 2
      assert_equal "All tests passed\n", @avatar.visible_files['output']
      assert_equal :green, @avatar.lights[-1].colour
      diff = differ.diff(@kata.id, @avatar.name, was_tag=1, now_tag=2)
      assert diff['hiker.c'].include?({'type'=>'deleted', 'line'=>'    return 6 * 9;', 'number'=>5})
      assert diff['hiker.c'].include?({'type'=>'added',   'line'=>'    return 6 * 7;', 'number'=>5})
    }
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  test 'BE8E40',
  'avatar.test() for an old kata seamlessly resurrects' do
    set_runner_class('RunnerService')
    in_kata {
      run_tests # 1
      assert_equal :red, @avatar.lights[-1].colour
      output = @avatar.visible_files['output']

      [
        "makefile:14: recipe for target 'test.output' failed",
        'Assertion failed: answer() == 42 (hiker.tests.c: life_the_universe_and_everything: 7)',
        'make: *** [test.output] Aborted'
      ].each do |expected|
        assert output.include?(expected)
        # Note that depending on the host's OS the last line might be
        #     make: *** [test.output] Aborted (core dumped)
        # viz with (core dumped) appended
      end

      runner.avatar_old(@kata.image_name, @kata.id, @avatar.name)
      runner.kata_old(@kata.image_name, @kata.id)

      change_file('hiker.c', content('hiker.c').sub('6 * 9', '6 * 7'))
      run_tests # 2
      assert_equal "All tests passed\n", @avatar.visible_files['output']
      assert_equal :green, @avatar.lights[-1].colour
      diff = differ.diff(@kata.id, @avatar.name, was_tag=1, now_tag=2)
      assert diff['hiker.c'].include?({'type'=>'deleted', 'line'=>'    return 6 * 9;', 'number'=>5})
      assert diff['hiker.c'].include?({'type'=>'added',   'line'=>'    return 6 * 7;', 'number'=>5})
    }
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  test 'BE8B75',
  'show-json (for Atom editor)' do
    create_gcc_assert_kata
    @avatar = start
    kata_edit
    run_tests
    params = { :format => :json, :id => @id, :avatar => @avatar.name }
    get 'kata/show_json', params
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  private

  def in_kata(choice = 'stateful')
    if choice == 'stateful'
      create_gcc_assert_kata
    end
    if choice == 'stateless'
      create_python_unittest_kata
    end
    @avatar = start
    begin
      yield @kata.id
    ensure
      if choice == 'stateful'
        runner.avatar_old(@kata.image_name, @kata.id, @avatar.name)
        runner.kata_old(@kata.image_name, @kata.id)
      end
    end
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  def create_gcc_assert_kata
    id = create_kata('C (gcc), assert') # stateful
    @kata = Kata.new(katas, id)
    id
  end

  def create_ruby_testunit_kata
    id = create_kata('Python, unittest') # stateless
    @kata = Kata.new(katas, id)
    id
  end

  def assert_file(filename, expected)
    assert_equal expected, @avatar.visible_files[filename]
  end

  def makefile_with_leading_spaces
    [
      'CFLAGS += -I. -Wall -Wextra -Werror -std=c11',
      'test: makefile $(C_FILES) $(COMPILED_H_FILES)',
      '    @gcc $(CFLAGS) $(C_FILES) -o $@'
    ].join("\n")
  end

  def makefile
    'makefile'
  end

end
