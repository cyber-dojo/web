require_relative 'app_services_test_base'

class RunnerStubTest < AppServicesTestBase

  def self.hex_prefix
    'AF7'
  end

  def hex_setup
    set_differ_class('NotUsed')
    set_storer_class('NotUsed')
    set_runner_class('RunnerStub')
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  test '2C0',
  'stub_run can stub stdout and leave',
  'stderr defaulted to stub empty-string and',
  'status defaulted to stub zero and',
  'colour defaulted to red' do
    runner.stub_run(expected='syntax error line 1')
    stdout,stderr,status,colour = runner.run(*unused_args)
    assert_equal expected, stdout
    assert_equal '', stderr
    assert_equal 0, status
    assert_equal 'red', colour
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  test '09C',
  'stdout,stderr,status,colour can all be stubbed explicitly' do
    expected_stdout = 'Assertion failed'
    expected_stderr = 'makefile...'
    expected_status = 2
    expected_colour = 'red'
    args = []
    args << expected_stdout
    args << expected_stderr
    args << expected_status
    args << expected_colour
    runner.stub_run(*args)
    stdout,stderr,status,colour = runner.run(*unused_args)
    assert_equal expected_stdout, stdout
    assert_equal expected_stderr, stderr
    assert_equal expected_status, status
    assert_equal expected_colour, colour
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  test '111',
  'run colour can be stubbed on its own' do
    runner.stub_run_colour('red')
    _,_,_,colour = runner.run(*unused_args)
    assert_equal 'red', colour

    runner.stub_run_colour('amber')
    _,_,_,colour = runner.run(*unused_args)
    assert_equal 'amber', colour

    runner.stub_run_colour('green')
    _,_,_,colour = runner.run(*unused_args)
    assert_equal 'green', colour
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  test '97A',
  'run without preceeding stub returns blah blah' do
    stdout,stderr,status,colour = runner.run(*unused_args)
    assert stdout.start_with? 'blah'
    assert_equal '', stderr
    assert_equal 0, status
    assert_equal 'red', colour
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  test '902',
  'stub set in one thread has to be visible in another thread',
  'because app_controller methods are routed into a new thread' do
    runner.stub_run(expected='syntax error line 1')
    stubbed_stdout = nil
    tid = Thread.new {
      stubbed_stdout,_stderr,_stdout,_colour = runner.run(*unused_args)
    }
    tid.join
    assert_equal expected, stubbed_stdout
  end

  private

  def unused_args
    args = []
    args << (image_name = nil)
    args << (kata_id = nil)
    args << (avatar_name = nil)
    args << (max_seconds = nil)
    args << (delta = nil)
    args << (files = nil)
    args
  end

end
