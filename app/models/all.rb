
%w(
  manifest_property

  dojo
  cache_properties
  start_points_rename
  start_points
  start_point
  exercises
  exercise
  katas
  kata
  avatars
  avatar
  tag
).each { |sourcefile| require_relative './' + sourcefile }
