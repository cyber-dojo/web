require_relative 'app_controller_test_base'

class AssetsTest < AppControllerTestBase

  test 'EB5001', %w(
  | hashed CSS path returns 200 with text/css and one-year immutable cache-control
  ) do
    get App::CSS_PATH
    assert_equal 200, last_response.status
    assert_includes last_response.content_type, 'text/css'
    cache_control = last_response.headers['Cache-Control']
    assert_includes cache_control, 'max-age=31536000', cache_control
    assert_includes cache_control, 'immutable', cache_control
  end

  test 'EB5002', %w(
  | hashed JS path returns 200 with text/javascript and one-year immutable cache-control
  ) do
    get App::JS_PATH
    assert_equal 200, last_response.status
    assert_includes last_response.content_type, 'text/javascript'
    cache_control = last_response.headers['Cache-Control']
    assert_includes cache_control, 'max-age=31536000', cache_control
    assert_includes cache_control, 'immutable', cache_control
  end

  test 'EB5003', %w(
  | each asset URL path embeds a short hash of its content, so any change
  | to the content yields a new URL that safely busts the immutable cache
  ) do
    assert_match(%r{\A/assets/app-[0-9a-f]{8}\.css\z}, App::CSS_PATH, App::CSS_PATH)
    assert_match(%r{\A/assets/app-[0-9a-f]{8}\.js\z}, App::JS_PATH, App::JS_PATH)
  end

end
