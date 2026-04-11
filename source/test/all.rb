
# This line must come first, before any required/loaded files to be covered.
require_relative './test_coverage'

app_root = File.expand_path('..', __dir__)

%w(
  lib
  app/models
  app/services
).each do |dir|
  Dir.glob("#{app_root}/#{dir}/*.rb").each { |filename|
    require filename
  }
end

require_relative './test_base'

require 'json'
