#!/bin/bash ../test_wrapper.sh

require_relative './app_controller_test_base'

class SetupCustomStartPointControllerTest < AppControllerTestBase

  test 'EB77D9',
  'show_exercises shows all exercises' do
    # This assumes the exercises volume is default-exercises (refactoring)
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
      exercises_display_names

    do_get 'show_exercises'

    assert /data-major\=\"Tennis refactoring/.match(html)
    assert /data-major\=\"Yahtzee refactoring/.match(html)

    assert /data-minor\=\"C# NUnit/.match(html), html

    params = {
      major: 'Tennis refactoring',
      minor: 'C# NUnit'
    }
    do_get 'save', params
  end

  # - - - - - - - - - - - - - - - - - - - - - -

  test '294C10',
  'pull_needed is true if docker image is not pulled' do
    params = {
      format: :js,
       major: 'Tennis refactoring',
       minor: 'Python unitttest'
    }
    do_get 'pull_needed', params
    assert json['pull_needed']
  end

  # - - - - - - - - - - - - - - - - - - - - - -

  test '9D3E9A',
  'pull_needed is false if docker image is pulled' do
    params = {
      format: :js,
       major: 'Tennis refactoring',
       minor: 'C# NUnit'
    }
    do_get 'pull_needed', params
    refute json['pull_needed']
  end

  # - - - - - - - - - - - - - - - - - - - - - -

  test '4694A0',
  'pull issues docker-pull command for appropriate image_name' do
    setup_mock_shell
    shell.mock_exec(
      ['docker pull cyberdojofoundation/python_unittest'],
      docker_pull_output,
      exit_success
    )
    params = {
      format: :js,
       major: 'Tennis refactoring',
       minor: 'Python unitttest'
    }
    do_get 'pull', params
    shell.teardown
  end

  # - - - - - - - - - - - - - - - - - - - - - -

  private

  def do_get(route, params = {})
    controller = 'setup_custom_start_point'
    get "#{controller}/#{route}", params
    assert_response :success
  end

  def exercises_display_names
    exercises.map(&:display_name).sort
  end

end
