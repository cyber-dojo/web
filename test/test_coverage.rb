require 'simplecov'

SimpleCov.start do
  modyule = ARGV[0]
  slashed_modyule = modyule.sub('_','/')
  add_group('test/'+modyule) { |src| src.filename.start_with?('/app/test/'+modyule+'/') }
  add_group(slashed_modyule) { |src| src.filename.start_with?('/app/'+slashed_modyule+'/') }
end

cov_root = File.expand_path('..', File.dirname(__FILE__))
SimpleCov.root cov_root
SimpleCov.coverage_dir ENV['COVERAGE_DIR']

#- - - - - - - - - - - - - - - - - - - - - - -
#filters.clear
#add_group('debug') { |src| puts "coverage:#{src.filename}"; false }
