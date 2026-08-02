
# This line must come first, before any required/loaded files to be covered.
require_relative './test_coverage'

# The image copies source/server/ to /web/source, so the app sits at
# /web/source/web in the container even though it is source/server/web here.
app_root = File.expand_path('../source/web', __dir__)

Dir.glob("#{app_root}/*.rb").each { |filename|
  # app.rb is required by the suites that exercise it. Requiring it here too
  # would add its lines to every suite's coverage denominator.
  next if File.basename(filename) == 'app.rb'

  require filename
}

# RunnerStub is the test suite's default runner (see test_external_helpers).
# Production code no longer requires it - externals.rb used to, which pulled
# the test tree into the shipped image.
require_relative './app_services/runner_stub'

require_relative './test_base'

require 'json'
