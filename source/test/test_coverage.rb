require 'simplecov'

SimpleCov.start do

  # what to cover
  root File.expand_path('..', __dir__)  
  # where coverage reports are written
  coverage_dir(ENV['COVERAGE_DIR'])
  # Silence 'failed to recognize the test framework' warning
  command_name('Unit Tests')

  web_home = '/web/source'
  modyule = ARGV[0]                      # eg 'app_helpers'
  slashed_modyule = modyule.sub('_','/') # eg 'app/helpers'

  add_group('test/'+modyule) { |src|
    src.filename.start_with?("#{web_home}/test/#{modyule}/")
  }
  # In Sinatra the "controller" is app/app.rb rather than app/controllers/
  src_path = (modyule == 'app_controllers') ? 'app/app.rb' : "#{slashed_modyule}/"
  add_group(slashed_modyule) { |src|
    src.filename.start_with?("#{web_home}/#{src_path}")
  }
end

#- - - - - - - - - - - - - - - - - - - - - - -
#filters.clear
#add_group('debug') { |src| puts "coverage:#{src.filename}"; false }
