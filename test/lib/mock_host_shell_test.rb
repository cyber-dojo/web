#!/bin/bash ../test_wrapper.sh

require_relative './lib_test_base'

class MockHostShellTest < LibTestBase

  # - - - - - - - - - - - - - - -
  # teardown
  # - - - - - - - - - - - - - - -

  test '4A5F79',
  'teardown does not raise if no mocks are setup and no calls are made' do
    assert_equal '4A5F79', test_id
    shell = MockHostShell.new(test_id)
    shell.teardown
  end

  # - - - - - - - - - - - - - - -

  test 'B4EA4E',
  'teardown does not raise if one mock exec setup and matching exec is made' do
    shell = MockHostShell.new(test_id)
    shell.mock_exec(pwd, wd, success)
    output,exit_status = shell.exec('pwd')
    assert_equal wd, output
    assert_equal success, exit_status
    shell.teardown
  end

  # - - - - - - - - - - - - - - -

  test 'E93DEE',
  'teardown does not raise if one mock cd_exec setup and matching cd_exec is made' do
    shell = MockHostShell.new(test_id)
    shell.mock_cd_exec(wd, pwd, wd, success)
    output,exit_status = shell.cd_exec(wd, 'pwd')
    assert_equal wd, output
    assert_equal success, exit_status
    shell.teardown
  end

  # - - - - - - - - - - - - - - -

  test 'D0C5BF',
  'teardown raises if one mock exec setup and no calls are made' do
    shell = MockHostShell.new(test_id)
    shell.mock_exec(pwd, wd, success)
    assert_raises { shell.teardown }
  end

  # - - - - - - - - - - - - - - -

  test '093B43',
  'teardown raises if one mock cd_exec setup and no calls are made' do
    shell = MockHostShell.new(test_id)
    shell.mock_cd_exec(wd, pwd, wd, success)
    assert_raises { shell.teardown }
  end

  # - - - - - - - - - - - - - - -
  # cd_exec
  # - - - - - - - - - - - - - - -

  test 'F00C49',
  'cd_exec raises if mock for exec has been setup' do
    shell = MockHostShell.new(test_id)
    shell.mock_exec(pwd, wd, success)
    assert_raises { shell.cd_exec(wd, pwd) }
  end

  # - - - - - - - - - - - - - - -

  test '77C7CB',
  'cd_exec raises if mock for cd_exec has dfferent cd-path' do
    shell = MockHostShell.new(test_id)
    shell.mock_cd_exec(wd, pwd, wd, success)
    assert_raises { shell.cd_exec(wd+'X', pwd) }
  end

  # - - - - - - - - - - - - - - -

  test 'E0578A',
  'cd_exec raises if mock for cd_exec has dfferent command' do
    shell = MockHostShell.new(test_id)
    shell.mock_cd_exec(wd, pwd, wd, success)
    assert_raises { shell.cd_exec(wd, pwd+pwd) }
  end

  # - - - - - - - - - - - - - - -
  # exec
  # - - - - - - - - - - - - - - -

  test '4C1ACE',
  'exec raises if mock for cd_exec has been setup' do
    shell = MockHostShell.new(test_id)
    shell.mock_cd_exec(wd, pwd, wd, success)
    assert_raises { shell.exec(pwd) }
  end

  # - - - - - - - - - - - - - - -

  test '181EC6',
  'exec raises if mock for exec has dfferent command' do
    shell = MockHostShell.new(test_id)
    shell.mock_exec(pwd, wd, success)
    assert_raises { shell.exec(not_pwd = "cd #{wd}") }
  end

  # - - - - - - - - - - - - - - -

  private

  def pwd; ['pwd']; end
  def wd; '/Users/jonjagger/repos/web'; end
  def success; 0; end

end
