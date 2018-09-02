
# This line must come first, before any required/loaded files to be covered.
require_relative './test_coverage'

web_home = '/cyber-dojo'

%w(
  lib
  app/helpers
  app/lib
  app/models
  app/services
).each do |dir|
  Dir.glob("#{web_home}/#{dir}/*.rb").each { |filename|
    require filename
  }
end

require_relative './test_base'

require 'json'
