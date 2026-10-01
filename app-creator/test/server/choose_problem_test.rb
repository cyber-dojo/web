require_relative 'creator_test_base'

class ChooseProblemTest < CreatorTestBase

  # - - - - - - - - - - - - - - - - -

  qtest B73w18: %w[
    |GET/choose_problem
    |offers all exercise_start_point names
  ] do
    get mounted_path('choose_problem')
    assert status?(200), status
    html = last_response.body
    exercises_start_points.names.each do |name|
      assert html =~ display_name_div(name), name
    end
  end
end
