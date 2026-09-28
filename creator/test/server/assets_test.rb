require_relative 'creator_test_base'

class AssetsTest < CreatorTestBase

  # - - - - - - - - - - - - - - - - -

  test 'Q3p2Je', %w[
    |the fingerprinted CSS path is served as css with a one-year
    |immutable Cache-Control header, so browsers do not re-pull it
    |through nginx's rate-limited /creator/ zone on every navigation
  ] do
    get mounted_asset_path(App::CSS_PATH)
    assert status?(200), status
    assert css_content?, content_type
    cache_control = last_response.headers['Cache-Control']
    assert_includes cache_control, 'max-age=31536000', cache_control
    assert_includes cache_control, 'immutable', cache_control
  end

  # - - - - - - - - - - - - - - - - -

  test 'Q3p3Je', %w[
    |the fingerprinted JS path is served as javascript with the
    |same one-year immutable Cache-Control header, as for 2Je
  ] do
    get mounted_asset_path(App::JS_PATH)
    assert status?(200), status
    assert js_content?, content_type
    cache_control = last_response.headers['Cache-Control']
    assert_includes cache_control, 'max-age=31536000', cache_control
    assert_includes cache_control, 'immutable', cache_control
  end

  # - - - - - - - - - - - - - - - - -

  test 'Q3p4Je', %w[
    |each asset's URL path embeds a short hash of its content, so
    |any change to the content yields a new URL that safely busts
    |the immutable browser cache on the next deploy
  ] do
    assert_match(%r{\A/assets/app-[0-9a-f]{8}\.css\z}, App::CSS_PATH, App::CSS_PATH)
    assert_match(%r{\A/assets/app-[0-9a-f]{8}\.js\z}, App::JS_PATH, App::JS_PATH)
  end

  # - - - - - - - - - - - - - - - - -

  test 'Q3p5Je', %w[
    |the layout links each asset by its fingerprinted path,
    |prefixed with /creator so the request routes through nginx
  ] do
    get mounted_path('home')
    assert status?(200), status
    html = last_response.body
    assert html.include?(%Q{href="#{mounted_asset_path(App::CSS_PATH)}"}), html
    assert html.include?(%Q{src="#{mounted_asset_path(App::JS_PATH)}"}), html
  end
end
