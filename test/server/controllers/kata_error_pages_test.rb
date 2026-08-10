require_relative 'controllers_test_base'
require_relative '../../capture_stdout_stderr'

class KataErrorPagesTest < ControllersTestBase

  include CaptureStdoutStderr

  test 'EB6001', %w(
  | GET /kata/edit2 (unknown route) returns 404
  ) do
    get '/kata/edit2'
    assert_equal 404, last_response.status
    assert_includes last_response.body, '404'
  end

  test 'EB6003', %w(
  | POST to an unknown route returns the styled 404, as a GET does. A
  | wildcard route can only answer the verb it is declared for, so the
  | fallback is a not_found hook rather than a route.
  ) do
    post '/kata/edit2'
    assert_equal 404, last_response.status
    assert_includes last_response.body, '404'
  end

  test 'EB6002', %w(
  | GET /kata/edit/:id with a bad id returns 500
  ) do
    KataApp.set :raise_errors, false
    begin
      capture_stdout_stderr { get '/kata/edit/123' }
      assert_equal 500, last_response.status
      assert_includes last_response.body, '500'
    ensure
      KataApp.set :raise_errors, true
    end
  end

end
