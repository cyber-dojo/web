
%w(
  start_point_chooser
  file_delta_maker
  diff_view
  review_file_picker
  ring_picker
  dashboard_td_gapper
  display_names_splitter
  id_splitter

  runner_service
  runner_stub
  storer_fake
  storer_service
  differ_service
  zipper_service

).each { |sourcefile| require_relative './' + sourcefile }

