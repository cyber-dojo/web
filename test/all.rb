
# This line must come first, before any required/loaded files to be covered.
require_relative './test_coverage'

%w(
  lib
  app/helpers
  app/lib
  app/models
  app/services
).each do |dir|
  Dir.glob("#{ENV['CYBER_DOJO_HOME']}/#{dir}/*.rb").each { |filename|
    require filename
  }
end

require_relative './test_base'

require 'json'
