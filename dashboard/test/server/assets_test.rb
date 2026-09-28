require_relative 'test_base'

class AssetsTest < TestBase

  # - - - - - - - - - - - - - - - - -

  test 'aB3kf1', %w[
    |the fingerprinted CSS path is served as css with a one-year
    |immutable Cache-Control header, so browsers do not re-pull it
    |through nginx's rate-limited /dashboard/ zone on every navigation
  ] do
    get mounted_asset_path(App::CSS_PATH)
    assert status?(200), status
    assert css_content?, content_type
    cache_control = last_response.headers['Cache-Control']
    assert_includes cache_control, 'max-age=31536000', cache_control
    assert_includes cache_control, 'immutable', cache_control
  end

  # - - - - - - - - - - - - - - - - -

  test 'aB3kf2', %w[
    |the fingerprinted JS path is served as javascript with the
    |same one-year immutable Cache-Control header, as for kf1
  ] do
    get mounted_asset_path(App::JS_PATH)
    assert status?(200), status
    assert js_content?, content_type
    cache_control = last_response.headers['Cache-Control']
    assert_includes cache_control, 'max-age=31536000', cache_control
    assert_includes cache_control, 'immutable', cache_control
  end

  # - - - - - - - - - - - - - - - - -

  test 'aB3kf3', %w[
    |each asset's URL path embeds a short hash of its content, so
    |any change to the content yields a new URL that safely busts
    |the immutable browser cache on the next deploy
  ] do
    assert_match(%r{\A/assets/app-[0-9a-f]{8}\.css\z}, App::CSS_PATH, App::CSS_PATH)
    assert_match(%r{\A/assets/app-[0-9a-f]{8}\.js\z}, App::JS_PATH, App::JS_PATH)
  end

  # - - - - - - - - - - - - - - - - -

  test 'aB3kf4', %w[
    |the layout links each asset by its fingerprinted path, under the mount
    |point. The app writes no prefix itself: path_to() prepends SCRIPT_NAME.
  ] do
    get mounted_path('show/aB3kf4'), {}, { 'HTTP_ACCEPT' => 'text/html' }
    assert status?(200), status
    html = last_response.body
    assert html.include?(%Q{href="#{mounted_asset_path(App::CSS_PATH)}"}), html
    assert html.include?(%Q{src="#{mounted_asset_path(App::JS_PATH)}"}), html
  end
end
