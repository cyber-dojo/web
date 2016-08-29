
%w(
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
  tag
).each { |sourcefile| require_relative './' + sourcefile }
