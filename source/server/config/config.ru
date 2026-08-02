$stdout.sync = true
$stderr.sync = true

require_relative '../web/app'
require_relative '../web/externals'

run WebApp::App.new(WebApp::Externals.new)
