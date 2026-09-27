$stdout.sync = true
$stderr.sync = true

require_relative '../web/apps/mounted_apps'
require_relative '../web/externals'

run Web.mounted(Web::Externals.new)
