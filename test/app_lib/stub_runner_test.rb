require_relative 'app_lib_test_base'

class StubRunnerTest < AppLibTestBase

  test 'AF7866',
  'pulled? is stubbed true only for 4 specific images' do
    kata_id = 'AF7866F900'
    assert runner.pulled? cdf('nasm_assert'), kata_id
    assert runner.pulled? cdf('gcc_assert'), kata_id
    assert runner.pulled? cdf('csharp_nunit'), kata_id
    assert runner.pulled? cdf('gpp_cpputest'), kata_id
    refute runner.pulled? cdf('csharp_moq'), kata_id
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  test 'AF72BD',
  'pull is no-op' do
    kata_id = 'AF72BDE0E1'
    runner.pull cdf('csharp_moq'), kata_id
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  test 'AF72C0',
  'stub_run can stub stdout and leave',
  'stderr defaulted to stub empty-string and',
  'status defaulted to stub zero' do
    runner.stub_run(expected='syntax error line 1')
    stdout,stderr,status = runner.run(*unused_args)
    assert_equal expected, stdout
    assert_equal '', stderr
    assert_equal 0, status
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  test 'AF709C',
  'stdout,stderr,status can all be stubbed explicitly' do
    expected_stdout = 'Assertion failed'
    expected_stderr = 'makefile...'
    expected_status = 2
    runner.stub_run(expected_stdout, expected_stderr, expected_status)
    stdout,stderr,status = runner.run(*unused_args)
    assert_equal expected_stdout, stdout
    assert_equal expected_stderr, stderr
    assert_equal expected_status, status
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  test 'AF797E',
  'run without preceeding stub returns blah blah' do
    stdout,stderr,status = runner.run(*unused_args)
    assert stdout.start_with? 'blah'
    assert_equal '', stderr
    assert_equal 0, status
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  test 'AF7902',
  'stub set in one thread has to be visible in another thread',
  'because app_controller methods are routed into a new thread' do
    runner.stub_run(expected='syntax error line 1')
    stubbed_stdout = nil
    tid = Thread.new {
      stubbed_stdout,_stderr,_stdout = runner.run(*unused_args)
    }
    tid.join
    assert_equal expected, stubbed_stdout
  end

  private

  def cdf(image)
    'cyberdojofoundation/' + image
  end

  def unused_args
    args = []
    args << (image_name = nil)
    args << (kata_id = nil)
    args << (avatar_name = nil)
    args << (deleted_filenames = nil)
    args << (changed_files = nil)
    args << (max_seconds = nil)
    args
  end

end
