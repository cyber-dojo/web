
%w(
  setup_chooser
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
).each { |sourcefile| require_relative './' + sourcefile }

