#!/bin/bash ../test_wrapper.sh

require_relative './app_controller_test_base'

class KataControllerTest  < AppControllerTestBase

  test 'BE876E',
  'run_tests with bad kata id raises' do
    params = { :format => :js, :id => 'bad' }
    assert_raises(StandardError) { post 'kata/run_tests', params }
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  test 'BE83FD',
  'run_tests with good kata id but bad avatar name raises' do
    kata_id = create_gcc_assert_kata
    params = { :format => :js, :id => kata_id, :avatar => 'bad' }
    assert_raises(StandardError) { post 'kata/run_tests', params }
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

  test 'BE80F6',
  'edit and then run-tests' do
    create_gcc_assert_kata
    @avatar = start
    kata_edit
    run_tests
    change_file('hiker.h', 'syntax-error')
    run_tests
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  test 'E77261',
  'run_tests does NOT save non-visible files back to storer' do
    set_runner_class('RunnerService')
    create_gcc_assert_kata
    @avatar = start
    begin
      run_tests
      # XXXX: storer.sandbox_path
      path = storer.sandbox_path(@kata.id, @avatar.name)
      dir = disk[path]
      filename = 'hiker.h'
      assert dir.exists?(filename), filename
      filename = 'test'
      refute dir.exists?(filename), filename
    ensure
      runner.old_kata(@kata.id)
    end
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  test 'BE87FD',
  'run_tests() saves changed makefile with leading spaces converted to tabs',
  'and these changes are made to the visible_files parameter too',
  'so they also occur in the manifest file' do
    set_runner_class('RunnerService')
    create_gcc_assert_kata
    @avatar = start
    begin
      kata_edit
      run_tests
      change_file(makefile, makefile_with_leading_spaces)
      run_tests
      assert_file makefile, makefile_with_leading_tab
    ensure
      runner.old_kata(@kata.id)
    end
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  test 'BE87AF',
  'run_tests() saves *new* makefile with leading spaces converted to tabs',
  'and these changes are made to the visible_files parameter too',
  'so they also occur in the manifest file' do
    set_runner_class('RunnerService')
    create_gcc_assert_kata
    @avatar = start
    begin
      delete_file(makefile)
      run_tests
      new_file(makefile, makefile_with_leading_spaces)
      run_tests
      assert_file makefile, makefile_with_leading_tab
    ensure
      runner.old_kata(@kata.id)
    end
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  test 'BE89DC',
  'when cyber-dojo.sh removes a file then it stays removed.' +
    '(viz, RunnerService is stateful)' do
    set_runner_class('RunnerService')
    create_gcc_assert_kata
    @avatar = start
    begin
      before = content('cyber-dojo.sh')
      filename = 'wibble.txt'
      create_file = "touch #{filename} &&  ls -al && #{before}"
      change_file('cyber-dojo.sh', create_file)
      hit_test
      output = @avatar.visible_files['output']
      assert output.include?(filename), output

      remove_file = "rm -f #{filename} && ls -al && #{before}"
      change_file('cyber-dojo.sh', remove_file)
      hit_test
      output = @avatar.visible_files['output']
      refute output.include?(filename), output

      ls_file = "ls -al && #{before}"
      change_file('cyber-dojo.sh', ls_file)
      hit_test
      output = @avatar.visible_files['output']
      refute output.include?(filename), output
    ensure
      runner.old_kata(@kata.id)
    end
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  test '97B555',
  'when RunnerService receives run() for an avatar in a kata started when',
  'the runner was not yet a separate service, then RunnerService seamlessly',
  'transitions the avatar' do
    # Note: the kata-controller validates the kata-id and the avatar-name
    # (via the host-katas-storer) so there is not a path from the browser to
    # get runner.run to accept unvalidated arguments.
    set_runner_class('RunnerService')
    create_gcc_assert_kata
    @avatar = start # 0
    hit_test # 1
    assert_equal :red, @avatar.lights[-1].colour
    output = @avatar.visible_files['output']

    [
      "makefile:14: recipe for target 'test.output' failed",
      "Assertion failed: answer() == 42 (hiker.tests.c: life_the_universe_and_everything: 7)",
      "make: *** [test.output] Aborted"
    ].each do |expected|
      assert output.include?(expected)
      # Note that depending on the host's OS the last line might be
      #     make: *** [test.output] Aborted (core dumped)
    end

    # remove runner's volume to simulate kata created before runner was a separate service.
    runner.old_avatar(@kata.id, @avatar.name)

    begin
      change_file('hiker.c', content('hiker.c').sub('6 * 9', '6 * 7'))
      hit_test # 2
      assert_equal "All tests passed\n", @avatar.visible_files['output']
      assert_equal :green, @avatar.lights[-1].colour
      diff = differ.diff(@avatar, was_tag=1, now_tag=2)
      assert diff['hiker.c'].include?({"type"=>"deleted", "line"=>"    return 6 * 9;", "number"=>5})
      assert diff['hiker.c'].include?({"type"=>"added",   "line"=>"    return 6 * 7;", "number"=>5})
    ensure
      runner.old_avatar(@kata.id, @avatar.name)
    end
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  private

  def create_gcc_assert_kata
    id = create_kata('C (gcc), assert')
    @kata = Kata.new(katas, id)
    id
  end

  def assert_file(filename, expected)
    assert_equal expected, @avatar.visible_files[filename], 'saved_to_manifest'
    # XXXX: storer.sandbox_path
    path = storer.sandbox_path(@kata.id, @avatar.name)
    assert_equal expected, disk[path].read(filename), 'saved_to_sandbox'
  end

  def makefile_with_leading_tab
    makefile_with_leading("\t")
  end

  def makefile_with_leading_spaces
    makefile_with_leading(' ' + ' ')
  end

  def makefile_with_leading(s)
    [
      "CFLAGS += -I. -Wall -Wextra -Werror -std=c11",
      "test: makefile $(C_FILES) $(COMPILED_H_FILES)",
      s + "@gcc $(CFLAGS) $(C_FILES) -o $@"
    ].join("\n")
  end

  def makefile
    'makefile'
  end

end
