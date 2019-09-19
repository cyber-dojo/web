require_relative 'app_services_test_base'
require_relative 'runner_stub'

class RunnerStubTest < AppServicesTestBase

  def self.hex_prefix
    'AF7'
  end

  def hex_setup
    set_runner_class('RunnerStub')
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  test '2C0',
  'stub_run can stub stdout and leave',
  'stderr defaulted to stub empty-string and',
  'status defaulted to stub zero and',
  'timed_out defaulted to false' do
    runner.stub_run(expected='syntax error line 1')
    result = runner.run_cyber_dojo_sh(*unused_args)
    assert_equal expected, result['stdout']['content']
    assert_equal '', result['stderr']['content']
    assert_equal 0, result['status']
    assert_equal false, result['timed_out']
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  test '09C',
  'stdout,stderr,status,timed_out can all be stubbed explicitly' do
    args = []
    args << (stdout='Assertion failed')
    args << (stderr='makefile...')
    args << (status=2)
    args << (timed_out=true)
    runner.stub_run(*args)
    result = runner.run_cyber_dojo_sh(*unused_args)
    assert_equal stdout, result['stdout']['content']
    assert_equal stderr, result['stderr']['content']
    assert_equal status, result['status']
    assert_equal timed_out, result['timed_out']
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  test '97A',
  'run without preceeding stub returns so/se/0/false' do
    result = runner.run_cyber_dojo_sh(*unused_args)
    assert_equal 'so', result['stdout']['content']
    assert_equal 'se', result['stderr']['content']
    assert_equal 0, result['status']
    assert_equal false, result['timed_out']
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  test '902',
  'stub set in one thread has to be visible in another thread',
  'because app_controller methods are routed into a new thread' do
    runner.stub_run(expected='syntax error line 1')
    result = nil
    tid = Thread.new {
      result = runner.run_cyber_dojo_sh(*unused_args)
    }
    tid.join
    assert_equal expected, result['stdout']['content']
  end

  private

  def unused_args
    args = []
    args << (image_name = nil)
    args << (kata_id = nil)
    args << (files = nil)
    args << (max_seconds = nil)
    args
  end

end
