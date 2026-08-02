require_relative 'app_controller_test_base'
require_relative 'capture_stdout_stderr'

class KataErrorPagesTest < AppControllerTestBase

  include CaptureStdoutStderr

  test 'EB6001', %w(
  | GET /kata/edit2 (unknown route) returns 404
  ) do
    get '/kata/edit2'
    assert_equal 404, last_response.status
    assert_includes last_response.body, '404'
  end

  test 'EB6002', %w(
  | GET /kata/edit/:id with a bad id returns 500
  ) do
    App.set :raise_errors, false
    begin
      capture_stdout_stderr { get '/kata/edit/123' }
      assert_equal 500, last_response.status
      assert_includes last_response.body, '500'
    ensure
      App.set :raise_errors, true
    end
  end

end
