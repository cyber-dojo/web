require_relative 'creator_test_base'

class ChooseCustomProblemTest < CreatorTestBase

  # - - - - - - - - - - - - - - - - -

  qtest A73w18: %w[
    |GET/choose_custom_problem
    |offers all custom_start_points names
  ] do
    get mounted_path('choose_custom_problem')
    assert status?(200), status
    html = last_response.body
    custom_start_points.names.each do |name|
      assert html =~ display_name_div(name), name
    end
  end
end
