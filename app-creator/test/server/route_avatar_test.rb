require_relative 'creator_test_base'

class RouteAvatarTest < CreatorTestBase

  # - - - - - - - - - - - - - - - - -

  qtest Av4B1a: %w[
    |GET /avatar
    |with an id saver rejects
    |returns the 400 html page
  ] do
    capture_io { get mounted_path('avatar'), { id: '123' } }
    assert status?(400), status
    assert html_content?, content_type
    assert last_response.body.include?('400'), last_response.body
  end
end
