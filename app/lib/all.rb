
%w(
  start_point_chooser
  file_delta_maker
  unit_test_framework_lookup
  differ_service
  diff_view
  review_file_picker
  ring_picker
  makefile_filter
  output_colour
  dashboard_td_gapper
  display_names_splitter
  host_disk_storer
  runner
  stub_runner
  docker_tar_pipe_runner
).each { |sourcefile| require_relative './' + sourcefile }

