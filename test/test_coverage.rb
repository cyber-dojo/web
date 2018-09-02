require 'simplecov'

SimpleCov.start do

  web_home = '/cyber-dojo'
  modyule = ARGV[0]                      # eg 'app_lib'
  slashed_modyule = modyule.sub('_','/') # eg 'app/lib'

  add_group('test/'+modyule) { |src|
    src.filename.start_with?("#{web_home}/test/#{modyule}/")
  }
  add_group(slashed_modyule) { |src|
    src.filename.start_with?("#{web_home}/#{slashed_modyule}/")
  }
end

cov_root = File.expand_path('..', File.dirname(__FILE__))
# what to cover
SimpleCov.root cov_root
# where coverage reports are written
SimpleCov.coverage_dir ENV['COVERAGE_DIR']

#- - - - - - - - - - - - - - - - - - - - - - -
#filters.clear
#add_group('debug') { |src| puts "coverage:#{src.filename}"; false }
