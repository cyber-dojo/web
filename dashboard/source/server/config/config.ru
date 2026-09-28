$stdout.sync = true
$stderr.sync = true

if ENV['CYBER_DOJO_PROMETHEUS'] === 'true'
  require 'prometheus/middleware/collector'
  require 'prometheus/middleware/exporter'
  use Prometheus::Middleware::Collector
  use Prometheus::Middleware::Exporter
end

require_relative '../dashboard/app'
require_relative '../dashboard/externals'
externals = DashboardApp::Externals.new

# The app owns its prefix: nginx passes it through untouched, so the app
# mounts itself there and SCRIPT_NAME tells it where it is.
run DashboardApp::App.mounted(externals)
