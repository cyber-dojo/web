
root = File.expand_path("../..", File.dirname(__FILE__))
%w( caches ).each do |dir|
  pathed_dir = root + '/' + dir
  Dir.mkdir(pathed_dir) unless File.exists?(pathed_dir)
end
