
%w(
  name_of_caller
  manifest_property

  dojo
  cache_properties
  start_point
  start_points_rename
  start_points
  exercise
  exercises
  kata
  avatar
  avatars
  sandbox
  tag
).each { |sourcefile| require_relative './' + sourcefile }
