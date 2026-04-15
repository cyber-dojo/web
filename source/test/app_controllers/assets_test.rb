require_relative 'app_controller_test_base'

class AssetsTest < AppControllerTestBase

  test 'EB5001', %w(
  | hashed CSS path returns 200 with text/css and one-year cache-control
  ) do
    get App::CSS_PATH
    assert_equal 200, last_response.status
    assert_includes last_response.content_type, 'text/css'
    assert_includes last_response.headers['Cache-Control'], 'max-age=31536000'
  end

  test 'EB5002', %w(
  | hashed JS path returns 200 with text/javascript and one-year cache-control
  ) do
    get App::JS_PATH
    assert_equal 200, last_response.status
    assert_includes last_response.content_type, 'text/javascript'
    assert_includes last_response.headers['Cache-Control'], 'max-age=31536000'
  end

  # These two tests cover the old bare paths that are still served via Sinatra's
  # static middleware. They are due to be retired once the bare paths are removed.

  test 'EB5003', %w(
  | /assets/app.css (unhashed) still returns 200
  ) do
    get '/assets/app.css'
    assert_equal 200, last_response.status
  end

  test 'EB5004', %w(
  | /assets/app.js (unhashed) still returns 200
  ) do
    get '/assets/app.js'
    assert_equal 200, last_response.status
  end

end
