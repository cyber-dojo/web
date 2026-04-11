$stdout.sync = true
$stderr.sync = true

require_relative 'app/app'

use Rack::Session::Cookie,
  key: '_cyber_dojo_session',
  secret: ENV.fetch('SECRET_KEY_BASE') { SecureRandom.hex(64) }

use Rack::Protection::AuthenticityToken

run App
