require 'rack/test'
require_relative '../id58_test_base'
require_source 'app'
require_source 'externals'

class TestBase < Id58TestBase
  include Rack::Test::Methods

  # The server app lives in the DashboardApp namespace. Including it here puts
  # that module in the ancestor chain of every test class, so tests name App,
  # Externals, TdGapper and friends unqualified.
  include DashboardApp

  # The same mounting config.ru runs, so a test drives the URLs a browser
  # drives and the app builds the same URLs back. Only the externals differ.
  def app
    App.mounted(externals)
  end

  def externals
    @externals ||= Externals.new
  end

  # The URL a browser uses for a route: the app's mount point plus the route.
  # Takes a bare route name, eg 'show/vntRcc'. It does not strip a leading
  # slash: accepting both forms hides a doubled-slash path.
  def mounted_path(route)
    "#{App::MOUNT_PATH}/#{route}"
  end

  # The same, for a path that already starts with a slash, eg the
  # fingerprinted asset paths in App::CSS_PATH and App::JS_PATH.
  def mounted_asset_path(path)
    "#{App::MOUNT_PATH}#{path}"
  end

  # True when the last response status matches expected.
  def status?(expected)
    status == expected
  end

  # The last response's HTTP status code.
  def status
    last_response.status
  end

  # True when the last response was served as CSS.
  def css_content?
    content_type == 'text/css;charset=utf-8'
  end

  # True when the last response was served as JavaScript.
  def js_content?
    content_type == 'text/javascript;charset=utf-8'
  end

  # The last response's Content-Type header.
  def content_type
    last_response.headers['Content-Type']
  end
end
