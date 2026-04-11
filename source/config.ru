$stdout.sync = true
$stderr.sync = true

require_relative 'app/app'

use Rack::Session::Cookie,
  key: '_cyber_dojo_session',
  secret: ENV.fetch('SECRET_KEY_BASE', 'cyber-dojo-dev-secret-key-at-least-30-chars!')

use Rack::Protection::AuthenticityToken

run App
