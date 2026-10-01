require_relative 'apps_test_base'
require_relative '../../capture_stdout_stderr'
require_relative '../services/http_json_requester_not_json_stub'

class KataErrorPagesTest < AppsTestBase

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
  | GET /kata/edit/:id with an id saver rejects returns the 400 html page
  ) do
    capture_stdout_stderr { get '/kata/edit/123' }
    assert_equal 400, last_response.status
    assert_includes last_response.content_type, 'text/html'
    assert_includes last_response.body, '400'
  end

  test 'EB6004', %w(
  | GET /kata/edit/:id when the saver answers a body that is not JSON returns
  | the 500 html page
  ) do
    externals.instance_exec { @http = HttpJsonRequesterNotJsonStub }
    capture_stdout_stderr { get '/kata/edit/5U2J18' }
    assert_equal 500, last_response.status
    assert_includes last_response.content_type, 'text/html'
    assert_includes last_response.body, '500'
  end

  test 'EB6005', %w(
  | GET /kata/edit/:id when a collaborator raises an error that carries no
  | status returns the 500 html page
  ) do
    externals.instance_exec { @saver = SaverKataManifestRaisesStub.new(self) }
    capture_stdout_stderr { get '/kata/edit/5U2J18' }
    assert_equal 500, last_response.status
    assert_includes last_response.content_type, 'text/html'
    assert_includes last_response.body, '500'
  end

end

# A SaverService whose kata_manifest raises a plain RuntimeError, so the error
# reaching the error hook has no status of its own.
class SaverKataManifestRaisesStub < Web::SaverService

  def kata_manifest(_id)
    raise 'kata_manifest raised'
  end

end
