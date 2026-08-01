$stdout.sync = true
$stderr.sync = true

require_relative 'app/app'
require_relative 'app/services/externals'

run App.new(Externals.new)
