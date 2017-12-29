
%w(
  differ_service
  starter_service
  storer_fake
  zipper_service
).each { |sourcefile|
  require_relative sourcefile
}

