require_relative 'creator_test_base'

class ChooseLanguageTest < CreatorTestBase

  # - - - - - - - - - - - - - - - - -

  qtest D73w18: %w[
    |GET/choose_ltf
    |offers all languages-start-points names
  ] do
    get mounted_path('choose_ltf')
    assert status?(200), status
    html = last_response.body
    languages_start_points.names.each do |name|
      assert html =~ display_name_div(name), name
    end
  end
end
