require_relative 'app_services_test_base'

class RunnerStubTest < AppServicesTestBase

  def self.hex_prefix
    'AF7'
  end

  def hex_setup
    set_differ_class('NotUsed')
    set_saver_class('NotUsed')
    set_runner_class('RunnerStub')
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  test '2C0',
  'stub_run can stub stdout and leave',
  'stderr defaulted to stub empty-string and',
  'status defaulted to stub zero and',
  'colour defaulted to red' do
    runner.stub_run(expected='syntax error line 1')
    result = runner.run_cyber_dojo_sh(*unused_args)
    assert_equal expected, result['stdout']
    assert_equal '', result['stderr']
    assert_equal 0, result['status']
    assert_equal 'red', result['colour']
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  test '09C',
  'stdout,stderr,status,colour can all be stubbed explicitly' do
    args = []
    args << (stdout='Assertion failed')
    args << (stderr='makefile...')
    args << (status=2)
    args << (colour='red')
    runner.stub_run(*args)
    result = runner.run_cyber_dojo_sh(*unused_args)
    assert_equal stdout, result['stdout']
    assert_equal stderr, result['stderr']
    assert_equal status, result['status']
    assert_equal colour, result['colour']
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  test '111',
  'run colour can be stubbed on its own' do
    runner.stub_run_colour('red')
    result = runner.run_cyber_dojo_sh(*unused_args)
    assert_equal 'red', result['colour']

    runner.stub_run_colour('amber')
    result = runner.run_cyber_dojo_sh(*unused_args)
    assert_equal 'amber', result['colour']

    runner.stub_run_colour('green')
    result = runner.run_cyber_dojo_sh(*unused_args)
    assert_equal 'green', result['colour']
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  test '97A',
  'run without preceeding stub returns blah blah' do
    result = runner.run_cyber_dojo_sh(*unused_args)
    assert_equal 'blah blah blah', result['stdout']
    assert_equal '', result['stderr']
    assert_equal 0, result['status']
    assert_equal 'red', result['colour']
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
    assert_equal expected, result['stdout']
  end

  private

  def unused_args
    args = []
    args << (runner_choice = nil)
    args << (image_name = nil)
    args << (kata_id = nil)
    args << (new_files = nil)
    args << (deleted_files = nil)
    args << (changed_files = nil)
    args << (unchanged_files = nil)
    args << (max_seconds = nil)
    args
  end

end
