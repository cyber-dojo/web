require_relative 'app_controller_test_base'

class SetOptionsTest  < AppControllerTestBase

  def self.hex_prefix
    'As9'
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  test 'B77',
  %w( set_colour() persists the colour option ) do
    set_runner_class('RunnerService')
    in_kata do |kata|
      post '/kata/set_colour', params:{ id:kata.id, value:'off' }
      assert_equal 'off', kata.colour
      post '/kata/set_colour', params:{ id:kata.id, value:'on' }
      assert_equal 'on', kata.colour
    end
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  test 'B78',
  %w( set_theme() persists the theme option ) do
    set_runner_class('RunnerService')
    in_kata do |kata|
      post '/kata/set_theme', params:{ id:kata.id, value:'light' }
      assert_equal 'light', kata.theme
      post '/kata/set_theme', params:{ id:kata.id, value:'dark' }
      assert_equal 'dark', kata.theme
    end
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  test 'B79',
  %w( set_predict() persists the predict option ) do
    set_runner_class('RunnerService')
    in_kata do |kata|
      post '/kata/set_predict', params:{ id:kata.id, value:'on' }
      assert_equal 'on', kata.predict
      post '/kata/set_predict', params:{ id:kata.id, value:'off' }
      assert_equal 'off', kata.predict
    end
  end

end
