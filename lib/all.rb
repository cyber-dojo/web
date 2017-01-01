
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

  host_shell
  host_disk
  host_dir
  memory_log
  stdout_log
}.each { |sourcefile| require_relative './' + sourcefile }
