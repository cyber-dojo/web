require_relative 'creator_test_base'

class RouteNotFoundTest < CreatorTestBase

  # - - - - - - - - - - - - - - - - -

  qtest Nf7K2a: %w[
    |GET an unknown route
    |returns the 404 error page.
    |Its button says oops.
  ] do
    get mounted_path('nonsense')
    assert status?(404), status
    assert html_content?, content_type
    assert_includes last_response.body, '<div id="error-page">'
    assert_includes last_response.body, '404 error'
    assert_includes last_response.body, '>oops</button>'
  end

  # - - - - - - - - - - - - - - - - -

  qtest Nf7K2b: %w[
    |POST to an unknown route
    |returns the 404 error page, as a GET does.
  ] do
    post mounted_path('nonsense')
    assert status?(404), status
    assert html_content?, content_type
    assert_includes last_response.body, '<div id="error-page">'
    assert_includes last_response.body, '404 error'
    assert_includes last_response.body, '>oops</button>'
  end
end
