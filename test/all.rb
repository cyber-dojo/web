
# This line must come first, before any required/loaded files to be covered.
# The browser tests set no COVERAGE_DIR: they drive the app in the serving
# puma process, where in-process line coverage cannot see it.
require_relative './test_coverage' if ENV['COVERAGE_DIR']

# The image copies source/server/ to /web/source, so the app sits at
# /web/source/web in the container even though it is source/server/web here.
# Naming that container path here keeps it in one place, as dashboard does.
def require_source(name)
  # Requires one production file, named without its path, eg 'saver_service'.
  require_relative "../source/web/#{name}"
end

app_root = File.expand_path('../source/web', __dir__)

# The collaborators only. The mounted apps live in apps/, which this glob does
# not reach, and are required by the suite that exercises them - requiring them
# here would add their lines to every suite's coverage denominator.
Dir.glob("#{app_root}/*.rb").each { |filename| require filename }

# RunnerStub is the test suite's default runner (see test_external_helpers).
# Production code no longer requires it - externals.rb used to, which pulled
# the test tree into the shipped image.
require_relative './app_services/runner_stub'

require_relative './test_base'

require 'json'
