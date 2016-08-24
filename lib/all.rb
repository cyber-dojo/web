
# this list has order dependencies

%w{
  name_of_caller
  external_parent_chainer

  time_now
  unique_id
  id_splitter
  line_splitter
  string_cleaner
  string_truncater
  stderr_redirect
  unslashed

  runner
  stub_runner
  docker_tar_pipe_runner

  host_shell
  mock_host_shell
  mock_proxy_host_shell
  host_disk
  host_dir
  host_git
  memory_log
  stdout_log
}.each { |sourcefile| require_relative './' + sourcefile }
