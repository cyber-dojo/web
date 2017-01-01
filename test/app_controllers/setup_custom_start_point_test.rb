require_relative 'app_controller_test_base'

class SetupCustomStartPointControllerTest < AppControllerTestBase

  def setup_runner_class
    set_runner_class('StubRunner')
  end

  def prepare
    set_storer_class('FakeStorer')
  end

  test 'EB77D9',
  'show shows all custom exercises' do
    prepare
    # Assumes the exercises volume is default refactoring exercises
    assert_equal [
      'Tennis refactoring, C# NUnit',
      'Tennis refactoring, C++ (g++) assert',
      'Tennis refactoring, Java JUnit',
      'Tennis refactoring, Python unitttest',
      'Tennis refactoring, Ruby Test::Unit',
      'Yahtzee refactoring, C# NUnit',
      'Yahtzee refactoring, C++ (g++) assert',
      'Yahtzee refactoring, Java JUnit',
      'Yahtzee refactoring, Python unitttest'
      ],
      custom_display_names

    do_get 'show'

    assert /data-major\=\"Tennis refactoring/.match(html)
    assert /data-major\=\"Yahtzee refactoring/.match(html)

    assert /data-minor\=\"C# NUnit/.match(html), html

    params = {
      'major' => 'Tennis refactoring',
      'minor' => 'C# NUnit'
    }
    do_get 'save', params
  end

  # - - - - - - - - - - - - - - - - - - - - - -

  private

  def do_get(route, params = {})
    controller = 'setup_custom_start_point'
    get "#{controller}/#{route}", params
    assert_response :success
  end

  # - - - - - - - - - - - - - - - - - - - - - -

  def custom_display_names
    custom.map(&:display_name).sort
  end

end
