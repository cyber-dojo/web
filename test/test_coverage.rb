require 'simplecov'

SimpleCov.start do

  # what to cover
  root File.expand_path('..', __dir__)  
  # where coverage reports are written
  coverage_dir(ENV['COVERAGE_DIR'])
  # Silence 'failed to recognize the test framework' warning
  command_name('Unit Tests')

  web_home = '/web/source/web'
  test_home = '/web/test'
  modyule = ARGV[0]                      # eg 'app_helpers'
  slashed_modyule = modyule.sub('_','/') # eg 'app/helpers'

  add_group('test/'+modyule) { |src|
    src.filename.start_with?("#{test_home}/#{modyule}/")
  }

  # Which production files each test module covers. Named individually, by
  # basename, because the ruby files sit flat in app/ rather than in a
  # directory per module. In Sinatra the "controller" is app.rb.
  group_files = {
    'lib'             => %w(cleaner.rb files_from.rb time_adapter.rb),
    'app_models'      => %w(kata.rb runner.rb),
    'app_services'    => %w(externals.rb runner_service.rb saver_service.rb
                            spooler_service.rb requester.rb responder.rb),
    'app_controllers' => %w(app_base.rb assets_app.rb fork_app.rb kata_app.rb
                            mounted_apps.rb probes_app.rb review_app.rb)
  }

  # A group naming no existing file reports 100% covered, so an unassigned
  # file would be silently ungated. Fail loudly instead.
  assigned = group_files.values.flatten
  Dir.glob("#{web_home}/**/*.rb").each do |filename|
    basename = File.basename(filename)
    unless assigned.include?(basename)
      raise "#{basename} belongs to no coverage group in test_coverage.rb"
    end
  end

  add_group(slashed_modyule) { |src|
    group_files.fetch(modyule).include?(File.basename(src.filename))
  }
end

#- - - - - - - - - - - - - - - - - - - - - - -
#filters.clear
#add_group('debug') { |src| puts "coverage:#{src.filename}"; false }
