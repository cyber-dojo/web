$stdout.sync = true
$stderr.sync = true

require_relative '../app/app'
require_relative '../app/externals'

run WebApp::App.new(WebApp::Externals.new)
