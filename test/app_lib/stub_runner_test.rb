require_relative './app_lib_test_base'

class StubRunnerTest < AppLibTestBase

  test '43E866',
  'pulled? is true only for 4 specific images' do
    assert runner.pulled? cdf('nasm_assert')
    assert runner.pulled? cdf('gcc_assert')
    assert runner.pulled? cdf('csharp_nunit')
    assert runner.pulled? cdf('gpp_cpputest')
    refute runner.pulled? cdf('csharp_moq')
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  test '0B42BD',
  'pull is no-op' do
    runner.pull cdf('csharp_moq')
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  test '84B2C0',
  'stub_run_output stubs output for subsequent run' do
    kata = make_kata
    lion = kata.start_avatar(['lion'])
    runner.stub_run_output(output='syntax error line 1')
    stdout,_stderr,_status = runner.run(*unused_args)
    assert_equal output, stdout
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  test 'AF797E',
  'run without preceeding stub returns blah blah' do
    kata = make_kata
    lion = kata.start_avatar(['lion'])
    stdout,_stderr,_status = runner.run(*unused_args)
    assert stdout.start_with? 'blah'
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - - - -

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
