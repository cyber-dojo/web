require 'simplecov'

modyule = ARGV[0]

SimpleCov.start do
  #filters.clear
  #add_group('debug') { |src| puts "coverage:#{src.filename}"; false }

  if modyule == 'app_helpers'
    add_group('test/app_helpers') { |src| src.filename.start_with?('/app/test/app_helpers/') }
    add_group('app/helpers')      { |src| src.filename.start_with?('/app/app/helpers/') }
  end
  if modyule == 'app_lib'
    add_group('test/app_lib') { |src| src.filename.start_with?('/app/test/app_lib/') }
    add_group('app/lib')      { |src| src.filename.start_with?('/app/app/lib/') }
  end
  if modyule == 'app_models'
    add_group('test/app_models') { |src| src.filename.start_with?('/app/test/app_models/') }
    add_group('app/models')      { |src| src.filename.start_with?('/app/app/models/') }
  end
  if modyule == 'app_controllers'
    add_group('test/app_controllers') { |src| src.filename.start_with?('/app/test/app_controllers/') }
    add_group('app/controllers')      { |src| src.filename.start_with?('/app/app/controllers/') }
  end
  if modyule == 'lib'
    add_group('test/lib') { |src| src.filename.start_with?('/app/test/lib/') }
    add_group('lib')      { |src| src.filename.start_with?('/app/lib/') }
  end

end

cov_root = File.expand_path('..', File.dirname(__FILE__))
SimpleCov.root cov_root
SimpleCov.coverage_dir ENV['COVERAGE_DIR']
