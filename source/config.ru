$stdout.sync = true
$stderr.sync = true

require_relative 'app/app'
require_relative 'app/services/externals'

run WebApp::App.new(WebApp::Externals.new)
