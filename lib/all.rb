
# this list has order dependencies

%w{
  unslashed
  env_var
  name_of_caller
  externals
  nearest_ancestors

  time_now
  unique_id
  string_cleaner

  http
  disk_host
  dir_host
  shell_host
  log_spy
  log_stdout
}.each { |sourcefile| require_relative './' + sourcefile }
