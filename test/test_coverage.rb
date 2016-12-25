require 'simplecov'
#require 'simplecov-json'
#SimpleCov.formatters = [
#  SimpleCov::Formatter::HTMLFormatter,
#  SimpleCov::Formatter::JSONFormatter,
#]

SimpleCov.start do

  home = ENV['CYBER_DOJO_HOME']
  modyule = ARGV[0]                          # eg 'app_lib'
  slashed_modyule = modyule.sub('_','/')     # eg 'app/lib'

  add_group('test/'+modyule) { |src|
    src.filename.start_with?("#{home}/test/#{modyule}/")
  }
  add_group(slashed_modyule) { |src|
    src.filename.start_with?("#{home}/#{slashed_modyule}/")
  }
end

cov_root = File.expand_path('..', File.dirname(__FILE__))
SimpleCov.root cov_root # what to cover
SimpleCov.coverage_dir ENV['COVERAGE_DIR'] # where coverage reports are written

#- - - - - - - - - - - - - - - - - - - - - - -
#filters.clear
#add_group('debug') { |src| puts "coverage:#{src.filename}"; false }
