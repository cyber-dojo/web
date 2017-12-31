require_relative 'app_controller_test_base'

class KataControllerTest  < AppControllerTestBase

  def self.hex_prefix
    'BE83BC'
  end

  def hex_setup
    set_runner_class('RunnerService')
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  test '76E',
  'run_tests with bad kata id raises' do
    params = {
      :format => :js,
      :id     => 'bad'
    }
    assert_raises(StandardError) {
      post '/kata/run_tests', params:params
    }
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  test '221',
  'run timed_out test' do
    in_kata('stateless') {
      # 'Python, unittest', Ubuntu based
      c = <<~PYTHON_CODE
      class Hiker:
          def answer(self):
              while True:
                  True
              return 6 * 9
      PYTHON_CODE
      change_file('hiker.py', c)
      run_tests
      assert @avatar.lights[-1].output.start_with?('Unable to complete')
      assert_equal :timed_out, @avatar.lights[-1].colour
    }
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  test '222',
  'run timed_out test' do
    in_kata('stateful') {
      # 'C (gcc), assert', Alpine based
      # !proper formatting or else you get [-Werror=misleading-indentation]
      c = <<~C_CODE
      #include "hiker.h"
      int answer(void)
      {
          for(;;)
            ;
          return 6 * 9;
      }
      C_CODE
      change_file('hiker.c', c)
      run_tests
      assert @avatar.lights[-1].output.start_with?('Unable to complete')
      assert_equal :timed_out, @avatar.lights[-1].colour
    }
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  test '223',
  'run red test' do
    in_kata('processful') {
      run_tests
      assert_equal :red, @avatar.lights[-1].colour
    }
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  test '224',
  'run amber test' do
    in_kata('stateful') {
      change_file('hiker.c', 'syntax-error')
      run_tests
      assert_equal :amber, @avatar.lights[-1].colour
    }
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  test '225',
  'run green test' do
    in_kata('stateful') {
      c = @avatar.visible_files['hiker.c']
      c = c.sub('return 6 * 9;', 'return 6 * 7;')
      change_file('hiker.c', c)
      run_tests
      assert_equal :green, @avatar.lights[-1].colour
    }
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

=begin
  test 'B29',
  'stateless run() caches info so it only issues a',
  'single command to storer to save ran_test result' do
    #set_storer_class('StorerFake') # add Call-Counts?
    puts "X:#{storer.class.name}:"
    in_kata('stateless') { |kata_id|
      kata_edit
      params = {
        :format => :js,
        :id     => kata_id,
        :runner_choice => @kata.runner_choice,
        :image_name => 'cyberdojofoundation/python_unittest',
        :avatar => @avatar.name
      }.merge(@params_maker.params)
      set_storer_class('NotUsed')
      post '/kata/run_tests', params:params
    }
  end
=end

  #- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  test '7FD',
  'run_tests() on makefile with leading spaces',
  'are NOT converted to tabs and traffic-light is amber' do
    in_kata('stateful') {
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

  test '02D',
  'a new file persists when the RunnerService is stateful' do
    in_kata('stateful') {
      filename = 'hello.txt'
      new_file(filename, 'Hello world')
      run_tests
      change_file('cyber-dojo.sh', 'ls -al')
      run_tests
      output = @avatar.visible_files['output']
      assert output.include?(filename), output
    }
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  test '9DC',
  'a deleted file stays deleted when the RunnerService is stateful' do
    in_kata('stateful') {
      filename = 'instructions'
      ls_all = 'ls -al'
      delete_file(filename)
      run_tests
      change_file('cyber-dojo.sh', 'ls -al')
      run_tests
      output = @avatar.visible_files['output']
      refute output.include?(filename), output
    }
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  test '569',
  'when cyber-dojo.sh creates a file then it disappears',
  'when RunnerService is stateless' do
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

  test '3FD',
  'run_tests with bad image_name raises and does not cause resurrection' do
    in_kata('stateful') { |kata_id|
      kata_edit
      params = {
        :format => :js,
        :id     => kata_id,
        :image_name => 'does_not/exist',
        :avatar => @avatar.name
      }
      assert_raises(StandardError) {
        post 'kata/run_tests', params:params.merge(@params_maker.params)
      }
    }
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  test '555',
  'avatar.test() for an old avatar seamlessly resurrects' do
    # Note: the kata-controller validates the kata-id and the avatar-name
    # (via the storer) so there is no path from the browser to
    # get runner.run to accept unvalidated arguments.
    in_kata('stateful') {
      run_tests # 1
      assert_equal :red, @avatar.lights[-1].colour
      output = @avatar.visible_files['output']

      [
        '[makefile:14: test.output] Aborted',
        'Assertion failed: answer() == 42'
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

  test 'E40',
  'avatar.test() for an old kata seamlessly resurrects' do
    in_kata('stateful') {
      run_tests # 1
      assert_equal :red, @avatar.lights[-1].colour
      output = @avatar.visible_files['output']

      [
        '[makefile:14: test.output] Aborted',
        'Assertion failed: answer() == 42'
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

  test 'B75',
  'show-json (for Atom editor)' do
    create_gcc_assert_kata
    @avatar = start
    kata_edit
    run_tests
    params = { :format => :json, :id => @id, :avatar => @avatar.name }
    get '/kata/show_json', params:params
  end

  private # = = = = = = = = = = = = = = = =

  def in_kata(choice)
    case choice
    when 'stateful'    then create_gcc_assert_kata
    when 'stateless'   then create_python_unittest_kata
    when 'processful'  then create_python_pytest_kata
    end
    @avatar = start
    begin
      yield @kata.id
    ensure
      unless choice == 'stateless'
        runner.avatar_old(@kata.image_name, @kata.id, @avatar.name)
        runner.kata_old(@kata.image_name, @kata.id)
      end
    end
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  def create_gcc_assert_kata
    id = create_language_kata('C (gcc), assert') # stateful
    @kata = Kata.new(katas, id)
  end

  def create_python_unittest_kata
    id = create_language_kata('Python, unittest') # stateless
    @kata = Kata.new(katas, id)
  end

  def create_python_pytest_kata
    id = create_language_kata('Python, py.test') # processful
    @kata = Kata.new(katas, id)
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

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
