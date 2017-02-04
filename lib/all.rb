
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

  disk_host
  dir_host
  host_shell
  memory_log
  stdout_log
}.each { |sourcefile| require_relative './' + sourcefile }
