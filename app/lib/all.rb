
%w(
  start_point_chooser
  start_point_checker
  file_delta_maker
  unit_test_framework_lookup
  git_diff_parser
  git_diff_builder
  git_diff
  line_splitter
  review_file_picker
  prev_next_ring
  makefile_filter
  output_colour
  td_gapper
  delta_maker
  display_names_splitter
  runner
  docker_tar_pipe_runner
  stub_runner
).each { |sourcefile| require_relative './' + sourcefile }

