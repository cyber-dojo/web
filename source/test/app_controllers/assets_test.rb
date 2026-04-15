require_relative 'app_controller_test_base'

class AssetsTest < AppControllerTestBase

  test 'EB5001', %w(
  | /assets/app.css returns 200 with text/css content-type
  ) do
    get '/assets/app.css'
    assert last_response.ok?
    assert_includes last_response.content_type, 'text/css'
  end

  test 'EB5002', %w(
  | /assets/app.js returns 200 with application/javascript content-type
  ) do
    get '/assets/app.js'
    assert last_response.ok?
    assert_includes last_response.content_type, 'text/javascript'
  end

end
