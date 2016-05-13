
%w(
  name_of_caller
  manifest_property

  dojo
  cache_info
  language
  languages_rename
  languages
  instruction
  instructions
  kata
  avatar
  avatars
  sandbox
  tag
).each { |sourcefile| require_relative './' + sourcefile }
