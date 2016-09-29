#!/bin/bash ../test_wrapper.sh

require_relative './lib_test_base'

class MockHostShellTest < LibTestBase

  def setup_mock_shell
    set_shell_class('MockHostShell')
  end

  # - - - - - - - - - - - - - - -
  # initialize
  # - - - - - - - - - - - - - - -

  test 'B51EFC',
  'MockHostShell ctor only sets mocks=[] when file does not already exist' do
    # when a test issues a controller GET then it goes through the rails routes
    # which creates a new MockHostShell object in a new thread.
    # So the Mock has to work when it is "re-created" in different threads
    setup_mock_shell
    shell_1 = MockHostShell.new(nil)
    shell_1.mock_exec(pwd, wd, success)
    shell_2 = MockHostShell.new(@test_id)
    output,exit_status = shell_2.exec('pwd')
    assert_equal wd, output
    assert_equal success, exit_status
    shell_2.teardown
  end

  # - - - - - - - - - - - - - - -
  # teardown
  # - - - - - - - - - - - - - - -

  test '4A5F79',
  'teardown does not raise when no mocks are setup and no calls are made' do
    assert_equal '4A5F79', ENV['CYBER_DOJO_TEST_ID']
    setup_mock_shell
    shell.teardown
  end

  # - - - - - - - - - - - - - - -

  test 'B4EA4E',
  'teardown does not raise when one mock exec setup and matching exec is made' do
    setup_mock_shell
    shell.mock_exec(pwd, wd, success)
    output,exit_status = shell.exec('pwd')
    assert_equal wd, output
    assert_equal success, exit_status
    shell.teardown
  end

  # - - - - - - - - - - - - - - -

  test 'E93DEE',
  'teardown does not raise when one mock cd_exec setup and matching cd_exec is made' do
    setup_mock_shell
    shell.mock_cd_exec(wd, pwd, wd, success)
    output,exit_status = shell.cd_exec(wd, 'pwd')
    assert_equal wd, output
    assert_equal success, exit_status
    shell.teardown
  end

  # - - - - - - - - - - - - - - -

  test 'D0C5BF',
  'teardown raises when one mock exec setup and no calls are made' do
    setup_mock_shell
    shell.mock_exec(pwd, wd, success)
    assert_raises { shell.teardown }
  end

  # - - - - - - - - - - - - - - -

  test '093B43',
  'teardown raises when one mock cd_exec setup and no calls are made' do
    setup_mock_shell
    shell.mock_cd_exec(wd, pwd, wd, success)
    assert_raises { shell.teardown }
  end

  # - - - - - - - - - - - - - - -
  # cd_exec
  # - - - - - - - - - - - - - - -

  test 'F00C49',
  'cd_exec raises when mock for exec has been setup' do
    setup_mock_shell
    shell.mock_exec(pwd, wd, success)
    assert_raises { shell.cd_exec(wd, pwd) }
  end

  # - - - - - - - - - - - - - - -

  test '77C7CB',
  'cd_exec raises when mock for cd_exec has dfferent cd-path' do
    setup_mock_shell
    shell.mock_cd_exec(wd, pwd, wd, success)
    assert_raises { shell.cd_exec(wd+'X', pwd) }
  end

  # - - - - - - - - - - - - - - -

  test 'E0578A',
  'cd_exec raises when mock for cd_exec has dfferent command' do
    setup_mock_shell
    shell.mock_cd_exec(wd, pwd, wd, success)
    assert_raises { shell.cd_exec(wd, pwd+pwd) }
  end

  # - - - - - - - - - - - - - - -
  # exec
  # - - - - - - - - - - - - - - -

  test '4C1ACE',
  'exec raises when mock for cd_exec has been setup' do
    setup_mock_shell
    shell.mock_cd_exec(wd, pwd, wd, success)
    assert_raises { shell.exec(pwd) }
  end

  # - - - - - - - - - - - - - - -

  test '181EC6',
  'exec raises when mock for exec has dfferent command' do
    setup_mock_shell
    shell.mock_exec(pwd, wd, success)
    assert_raises { shell.exec(not_pwd = "cd #{wd}") }
  end

  # - - - - - - - - - - - - - - -

  private

  def pwd; ['pwd']; end
  def wd; '/Users/jonjagger/repos/web'; end
  def success; 0; end

end
