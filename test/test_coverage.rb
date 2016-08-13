require 'simplecov'

SimpleCov.start do
  filters.clear
  add_group 'app/controllers', 'app/controllers'
  add_group 'app/models',      'app/models'
  add_group 'app/helpers',     'app/helpers'
  add_group 'app/lib',         'app/lib'
  #add_group('lib') { |src| src.filename.include?('cyber-dojo/lib') }
  add_group('lib') { |src|
    src.filename.include?('web/lib') ||       # running tests locally
    src.filename.include?('cyber-dojo/lib')   # running tests inside web container
  }
end

cov_root = File.expand_path('..', File.dirname(__FILE__))
SimpleCov.root cov_root
