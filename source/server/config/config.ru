$stdout.sync = true
$stderr.sync = true

require_relative '../web/mounted_apps'
require_relative '../web/externals'

run WebApp.mounted(WebApp::Externals.new)
