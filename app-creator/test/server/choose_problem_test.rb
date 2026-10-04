require_relative 'creator_test_base'

class ChooseProblemTest < CreatorTestBase

  # - - - - - - - - - - - - - - - - -

  qtest B73w18: %w[
    |GET/choose_problem?type=group
    |redirects to /setup, keeping its query string
  ] do
    get mounted_path('choose_problem?type=group')
    assert status?(302), status
    assert_equal "http://example.org#{mounted_path('setup?type=group')}",
                 last_response.headers['Location']
  end
end
