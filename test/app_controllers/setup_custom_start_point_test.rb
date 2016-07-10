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
    assert_response :success

    assert /data-language\=\"Tennis refactoring/.match(html)
    assert /data-language\=\"Yahtzee refactoring/.match(html)

    assert /data-test\=\"C# NUnit/.match(html), html

    params = {
      language: 'Tennis refactoring',
          test: 'C# NUnit'
    }
    do_get 'save', params
    assert_response :success
  end

  # - - - - - - - - - - - - - - - - - - - - - -

  test '294C10',
  'pull_needed is true if docker image is not pulled' do
    params = {
      format: :js,
      language: 'Tennis refactoring',
          test: 'Python unitttest'
    }
    do_get 'pull_needed', params
    assert_response :success
    assert_equal true, json['pull_needed']
  end

  # - - - - - - - - - - - - - - - - - - - - - -

  test '9D3E9A',
  'pull_needed is false if docker image is pulled' do
    params = {
      format: :js,
      language: 'Tennis refactoring',
          test: 'C# NUnit'
    }
    do_get 'pull_needed', params
    assert_response :success
    assert_equal false, json['pull_needed']
  end

  # - - - - - - - - - - - - - - - - - - - - - -

  test '4694A0',
  'pull issues docker-pull command for appropriate image_name' do
    #set_shell_class('MockHostShell')
    #shell.mock_exec("docker pull cyberdojofoundation/python_unittest", '', 0)
    params = {
      format: :js,
      language: 'Tennis refactoring',
          test: 'Python unitttest'
    }
    do_get 'pull', params
    assert_response :success
    #shell.teardown
  end

  private

  def do_get(route, params = {}); get "#{controller}/#{route}", params; end
  def controller; 'setup_custom_start_point'; end

  def exercises_display_names; exercises.map(&:display_name).sort; end

end
