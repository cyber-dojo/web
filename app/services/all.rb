
%w(
  differ_service
  starter_service
  runner_service
  runner_stub
  storer_fake
  storer_service
  zipper_service
).each { |sourcefile|
  require_relative sourcefile
}

