require_relative 'test_base'
require 'json'
require 'rack/builder'

class ConfigRuMountsDashboardPrefixOnlyTest < TestBase
  # The suite normally drives App directly, which mounts it at the root. This
  # file needs the rack app config.ru builds, because everything here is about
  # the app being mounted under /dashboard.
  def app
    @app ||= Rack::Builder.parse_file(
      File.expand_path('../../source/config/config.ru', __dir__)
    )
  end

  test 'cnfg21', %w(
  | config.ru serves /alive under its /dashboard mount only. The bare path is
  | not served: nginx passes the prefix through rather than stripping it, so
  | nothing asks for /alive any more.
  ) do
    get '/dashboard/alive'
    assert_equal 200, last_response.status, last_response.body
    assert_equal({ 'alive?' => true }, JSON.parse(last_response.body))

    get '/alive'
    assert_equal 404, last_response.status, last_response.body
  end
end
