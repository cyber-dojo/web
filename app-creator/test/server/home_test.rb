require_relative 'creator_test_base'

class HomeTest < CreatorTestBase

  # - - - - - - - - - - - - - - - - -

  qtest Ws9w18: %w[
    |GET/home is 200
  ] do
    get mounted_path('home')
    assert status?(200), status
  end
end
