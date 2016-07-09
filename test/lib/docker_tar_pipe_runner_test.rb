#!/bin/bash ../test_wrapper.sh

require_relative './lib_test_base'

class DockerTarPipeRunnerTest < LibTestBase

  def setup
    super
    set_shell_class 'MockHostShell'
    set_runner_class 'DockerTarPipeRunner'
  end

  def teardown
    shell.teardown
    super
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  test '22CD45',
  'pulled? returns true when docker image is already pulled' do
    shell.mock_exec([sudo_docker_images], docker_images_python_pytest, success)
    display_name = 'Python, py.test'
    image_name = languages[display_name].image_name
    assert runner.pulled?(image_name)
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  test '342EF2',
  'pulled? returns false when docker image is not already pulled' do
    shell.mock_exec([sudo_docker_images], docker_images_python_pytest, success)
    display_name = 'Python, py.test'
    not_image_name = languages[display_name].image_name + 'X'
    refute runner.pulled?(not_image_name)
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  test '44BF36',
  'pull issues shell command [docker pull image]' do
    image_name = "#{cdf}/csharp_moq"
    command = [sudo, 'docker', 'pull', image_name].join(space).strip
    shell.mock_exec([command], any_output, success)
    runner.pull(image_name)
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  test '6459A7',
  'when run() completes and output is less than 10K',
  'then output is left untouched' do
    syntax_error = 'syntax-error-line-1'
    mock_run_assert(syntax_error, syntax_error, success)
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  test '87A438',
  'when run() completes and output is larger than 10K',
  'then output is truncated to 10K and it-got-truncated-message is appended' do
    massive_output = '.' * 75*1024
    expected_output = '.' * 10*1024 + "\n" + 'output truncated by cyber-dojo server'
    mock_run_assert(expected_output, massive_output, success)
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  test 'B8750C',
  'when run() times out',
  'then output is replaced by unable-to-complete message' do
    output = mock_run('ach-so-it-timed-out', times_out)
    max_seconds = dojo.env('runner_timeout')
    expected = "Unable to complete the tests in #{max_seconds} seconds."
    assert output.start_with?(expected), output
  end

  private

  def mock_run_assert(expected_output, mock_output, mock_exit_status)
    output = mock_run(mock_output, mock_exit_status)
    assert_equal expected_output, output
  end

  # - - - - - - - - - - - - - - -

  def mock_run(mock_output, mock_exit_status)
    lion = mock_run_setup(mock_output, mock_exit_status)
    delta = { deleted: {}, new: {}, changed: {} }
    runner.run(lion, delta, files={}, lion.kata.language.image_name)
  end

  # - - - - - - - - - - - - - - -

  def mock_run_setup(mock_output, mock_exit_status)
    kata = make_kata
    lion = kata.start_avatar(['lion'])
    args = [
      katas.path_of(lion.sandbox),
      kata.language.image_name,
      dojo.env('runner_timeout'),
      quoted(sudo)
    ].join(space = ' ')

    shell.mock_cd_exec(
      runner.path,
      ["./docker_tar_pipe_runner.sh #{args}"],
      mock_output,
      mock_exit_status
   )
   lion
  end

  # - - - - - - - - - - - - - - -

  def docker_images_python_pytest
    [
      'REPOSITORY             TAG     IMAGE ID      CREATED        VIRTUAL SIZE',
      '<none>                 <none>  b7253690a1dd  2 weeks ago    1.266 GB',
      "#{cdf}/python_pytest   latest  d9603e342b22  13 months ago  692.9 MB",
      '<none>                 <none>  0ebf80aa0a8a  2 weeks ago    569.8 MB'
    ].join("\n")
  end

  # - - - - - - - - - - - - - - -

  def sudo; dojo.env('runner_sudo'); end
  def sudo_docker_images; [sudo, 'docker', 'images'].join(space).strip; end
  def quoted(s); "'" + s + "'"; end
  def space; ' '; end
  def any_output; 'sdsd'; end
  def cdf; 'cyberdojofoundation'; end
  def times_out; fatal_error(kill); end
  def success; 0; end
  def kill; 9; end
  def fatal_error(signal); 128 + signal; end

end
