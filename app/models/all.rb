
%w(
  name_of_caller
  manifest_property

  dojo
  cache_properties
  languages_rename
  start_point
  start_points
  exercise
  exercises
  kata
  avatar
  avatars
  sandbox
  tag
).each { |sourcefile| require_relative './' + sourcefile }
