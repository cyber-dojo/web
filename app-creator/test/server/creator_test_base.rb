require_relative '../id58_test_base'

# The image copies source/server/ to /app/source, so the server app sits at
# /app/source/creator in its container. The client's container has its own
# layout, so each suite names its own path here rather than sharing one.
def require_source(required)
  require_relative "../../source/creator/#{required}"
end

require_source 'app'
require_source 'externals'
require 'cgi/escape'
require 'json'
require 'ostruct'

class CreatorTestBase < Id58TestBase
  include Rack::Test::Methods

  # The server app lives in the CreatorApp namespace. Including it here puts that
  # module in the ancestor chain of every test class, so tests name App, Externals,
  # HttpJsonHash::ServiceError and friends unqualified, as they did before the
  # namespace existed.
  include CreatorApp

  # Mounted the way config.ru mounts it, so a test drives the URLs a browser
  # drives and the app builds the same URLs back. Only the externals differ.
  def app
    App.mounted(externals)
  end

  def externals
    @externals ||= Externals.new
  end

  # - - - - - - - - - - - - - - - -

  def assert_get_200_json(path, args = {}, &block)
    stdout, stderr = capture_io do
      get path_with_args(path, args)
    end
    assert_equal 200, status, stderr + stdout
    assert json_content?, content_type
    assert_equal '', stderr, :stderr
    assert_equal '', stdout, :stdout
    block.call(json_response)
  end

  def assert_get_200_html(path, args = {})
    stdout, stderr = capture_io do
      get path_with_args(path, args)
    end
    assert_equal 200, status, stderr + stdout
    assert html_content?, content_type
    assert_equal '', stderr, :stderr
    assert_equal '', stdout, :stdout
  end

  # The URL a browser uses for a route: the app's mount point plus the route.
  # Takes a bare route name, eg 'home'. It does not strip a leading slash:
  # accepting both forms is how '/creator/home' once became '//creator/home'.
  def mounted_path(route)
    "#{App::MOUNT_PATH}/#{route}"
  end

  # The same, for a path that already starts with a slash, eg the
  # fingerprinted asset paths in App::CSS_PATH and App::JS_PATH.
  def mounted_asset_path(path)
    "#{App::MOUNT_PATH}#{path}"
  end

  def path_with_args(path, args)
    arg_pairs = args.map { |name, value| "#{name}=#{CGI.escape(value)}" }.join('&')
    "#{mounted_path(path)}?#{arg_pairs}"
  end

  # - - - - - - - - - - - - - - - -

  def assert_post_200_json(path, args, &block)
    stdout, stderr = capture_io do
      json_post mounted_path(path), args
    end
    assert_equal 200, status, stderr + stdout
    assert json_content?, content_type
    assert_equal '', stderr, :stderr
    assert_equal '', stdout, :stdout
    block.call(json_response)
  end

  # - - - - - - - - - - - - - - - -

  def json_post(path, data)
    post path, data.to_json, JSON_REQUEST_HEADERS
  end

  def json_response
    JSON.parse(last_response.body)
  end

  JSON_REQUEST_HEADERS = {
    'CONTENT_TYPE' => 'application/json', # sent request
    'HTTP_ACCEPT' => 'application/json'   # received response
  }.freeze

  private

  def custom_start_points
    externals.custom_start_points
  end

  def exercises_start_points
    externals.exercises_start_points
  end

  def languages_start_points
    externals.languages_start_points
  end

  def saver
    externals.saver
  end

  # - - - - - - - - - - - - - - -

  def status?(expected)
    status == expected
  end

  def status
    last_response.status
  end

  # - - - - - - - - - - - - - - -

  def html_content?
    content_type == 'text/html;charset=utf-8'
  end

  def css_content?
    content_type == 'text/css;charset=utf-8'
  end

  def js_content?
    content_type == 'text/javascript;charset=utf-8'
  end

  def json_content?
    content_type == 'application/json'
  end

  def content_type
    last_response.headers['Content-Type']
  end

  # - - - - - - - - - - - - - - -

  def escape_html(text)
    Rack::Utils.escape_html(text)
  end

  # - - - - - - - - - - - - - - -

  def cluster_exists?(id)
    saver.cluster_exists?(id)
  end

  def group_exists?(id)
    saver.group_exists?(id)
  end

  def kata_exists?(id)
    saver.kata_exists?(id)
  end

  # - - - - - - - - - - - - - - -

  def cluster_manifest(id)
    saver.cluster_manifest(id)
  end

  def group_manifest(id)
    saver.group_manifest(id)
  end

  def kata_manifest(id)
    saver.kata_manifest(id)
  end

  # - - - - - - - - - - - - - - -

  def display_name_div(display_name)
    name = Regexp.quote(escape_html(display_name))
    %r{<div class="display-name"\s*data-name=".*"\s*data-index=".*">\s*#{name}\s*</div>}
  end
end
