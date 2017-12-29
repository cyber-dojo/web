
%w(
  file_delta_maker
  diff_view
  review_file_picker
  ring_picker
  dashboard_td_gapper
  id_splitter

  runner_service

).each { |sourcefile|
  require_relative sourcefile
}

