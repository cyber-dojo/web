#!/bin/bash ../test_wrapper.sh

require_relative './lib_test_base'

class MockProxyHostShellTest < LibTestBase

  def setup
    super
    set_shell_class('MockProxyHostShell')
  end

  # - - - - - - - - - - - - - - -
  # teardown
  # - - - - - - - - - - - - - - -

  test '5839E8',
  'teardown does not raise if no mocks are setup and no calls are made' do
    assert_equal 'MockProxyHostShell', shell.class.name
    shell.teardown
  end

  # - - - - - - - - - - - - - - -

  test 'C3467F',
  'teardown does not raise if exec() calls have matching mock_exec()s' do
    shell.mock_exec(pwd, wd, success)
    output,exit_status = shell.exec('pwd')
    assert_equal wd, output
    assert_equal success, exit_status
    shell.teardown
  end

  # - - - - - - - - - - - - - - -

  test 'D75668',
  'teardown does not raise if cd_exec() calls have matching mock_cd_exec()s' do
    shell.mock_cd_exec(wd, pwd, wd, success)
    output,exit_status = shell.cd_exec(wd, 'pwd')
    assert_equal wd, output
    assert_equal success, exit_status
    shell.teardown
  end

  # - - - - - - - - - - - - - - -

  test '2B5145',
  'teardown raises if unrequited mock_exec() calls exist' do
    shell.mock_exec(pwd, wd, success)
    assert_raises { shell.teardown }
  end

  # - - - - - - - - - - - - - - -

  test '3BC432',
  'teardown raises if unrequited mock_cd_exec() calls exist' do
    shell.mock_cd_exec(wd, pwd, wd, success)
    assert_raises { shell.teardown }
  end

  # - - - - - - - - - - - - - - -
  # cd_exec
  # - - - - - - - - - - - - - - -

  test '41E610',
  'cd_exec raises if mock for cd_exec has dfferent cd-path' do
    shell.mock_cd_exec(wd, pwd, wd, success)
    assert_raises { shell.cd_exec(wd+'x', pwd) }
  end

  # - - - - - - - - - - - - - - -

  test '38E201',
  'cd_exec raises if mock for cd_exec has dfferent command' do
    shell.mock_cd_exec(wd, pwd, wd, success)
    assert_raises { shell.cd_exec(wd, pwd+'x') }
  end

  # - - - - - - - - - - - - - - -
  # exec
  # - - - - - - - - - - - - - - -

  test 'B5E542',
  'exec raises if mock for exec has dfferent command' do
    shell.mock_exec(pwd, wd, success)
    assert_raises { shell.exec(not_pwd = "cd #{wd}") }
  end

  # - - - - - - - - - - - - - - -
  # exec
  # - - - - - - - - - - - - - - -

  test '8E667B',
  'shell.success is zero' do
    assert_equal 0, shell.success
  end

  # - - - - - - - - - - - - - - -

  private

  def pwd; ['pwd']; end
  def wd; '/Users/jonjagger/repos/web'; end
  def success; 0; end

end
