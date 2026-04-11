require_relative 'app_controller_test_base'

class AssetsTest < AppControllerTestBase

  def self.hex_prefix
    'EB5'
  end

  test '001', %w(
  | /assets/app.css returns 200 with text/css content-type
  ) do
    get '/assets/app.css'
    assert last_response.ok?
    assert_includes last_response.content_type, 'text/css'
  end

  test '002', %w(
  | /assets/app.js returns 200 with application/javascript content-type
  ) do
    get '/assets/app.js'
    assert last_response.ok?
    assert_includes last_response.content_type, 'application/javascript'
  end

end
