$stdout.sync = true
$stderr.sync = true

require_relative '../code/app'
require_relative '../code/externals'
externals = Externals.new
run App.new(externals)
