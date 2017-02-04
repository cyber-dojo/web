
%w(
  start_point_chooser
  file_delta_maker
  unit_test_framework_lookup
  diff_view
  review_file_picker
  ring_picker
  makefile_filter
  output_colour
  dashboard_td_gapper
  display_names_splitter
  id_splitter
  stub_ragger

  puller_service
  puller_mock
  runner_service
  runner_stub
  storer_fake
  storer_service
  differ_service
  ragger_service

).each { |sourcefile| require_relative './' + sourcefile }

