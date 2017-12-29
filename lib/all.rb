
# this list has order dependencies

%w{
  name_of_caller
  nearest_ancestors
  time_now
  unique_id
  string_cleaner
}.each { |sourcefile| require_relative sourcefile }
