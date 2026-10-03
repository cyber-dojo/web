require_relative 'creator_test_base'

class ChooseLanguageTest < CreatorTestBase

  # - - - - - - - - - - - - - - - - -

  qtest D73w18: %w[
    |GET/choose_ltf?type=kata&exercise_name=Tennis
    |redirects to /setup, keeping its query string
  ] do
    get mounted_path('choose_ltf?type=kata&exercise_name=Tennis')
    assert status?(302), status
    assert_equal "http://example.org#{mounted_path('setup?type=kata&exercise_name=Tennis')}",
                 last_response.headers['Location']
  end
end
