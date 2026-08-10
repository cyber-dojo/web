
# This line must come first, before any required/loaded files to be covered.
# The browser tests set no COVERAGE_ROOT: they drive the app in the serving
# puma process, where in-process line coverage cannot see it.
# The else arm of this condition is "coverage is not running", so no run that
# measures coverage can ever record it. :nocov: keeps that impossible branch
# out of the totals rather than leaving it as a permanent missed branch.
# :nocov:
require_relative './coverage' if ENV['COVERAGE_ROOT']
# :nocov:

# The image copies source/server/ to /web/source, so the app sits at
# /web/source/web in the container even though it is source/server/web here.
# Naming that container path here keeps it in one place.
def require_source(name)
  # Requires one production file, named without its path, eg 'saver_service'.
  require_relative "../source/web/#{name}"
end

app_root = File.expand_path('../source/web', __dir__)

# The collaborators only. The mounted apps live in apps/, which this glob does
# not reach; controllers_test_base requires them. Coverage counts them
# either way - coverage.rb tracks every file under source/web/.
Dir.glob("#{app_root}/*.rb").each { |filename| require filename }

# RunnerStub is the test suite's default runner (see test_external_helpers).
# It lives in the test tree and is required from here, so that nothing in
# source/ reaches into test/ and pulls the test tree into the shipped image.
require_relative './services/runner_stub'

require 'json'
