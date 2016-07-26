#!/bin/bash ../test_wrapper.sh

require_relative './app_controller_test_base'

class SetupCustomStartPointControllerTest < AppControllerTestBase

  test 'EB77D9',
  'show shows all custom exercises' do
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
      custom_display_names

    do_get 'show'

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
  'pull.needed is true if docker image is not pulled' do
    do_get 'pull_needed', major_minor_js('Tennis refactoring', 'Python unitttest')
    assert json['needed']
  end

  # - - - - - - - - - - - - - - - - - - - - - -

  test '9D3E9A',
  'pull_needed is false if docker image is pulled' do
    do_get 'pull_needed', major_minor_js('Tennis refactoring', 'C# NUnit')
    refute json['needed']
  end

  # - - - - - - - - - - - - - - - - - - - - - -

  test '4694A0',
  'pull issues docker-pull image_name command and returns succeeded=true if pull succeeds' do
    setup_mock_shell
    shell.mock_exec(
      ['docker pull cyberdojofoundation/python_unittest'],
      docker_pull_output,
      exit_success
    )
    do_get 'pull', major_minor_js('Tennis refactoring', 'Python unitttest')
    assert json['succeeded']
    shell.teardown
  end

  # - - - - - - - - - - - - - - - - - - - - - -

  test '05C5E7',
  'pull issues docker-pull image_name command and returns succeeded=false if pull fails' do
    setup_mock_shell
    shell.mock_exec(
      ['docker pull cyberdojofoundation/python_unittest'],
      any_output='sdfsdfsdf',
      exit_failure=34
    )
    do_get 'pull', major_minor_js('Tennis refactoring', 'Python unitttest')
    refute json['succeeded']
    shell.teardown
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

  # - - - - - - - - - - - - - - - - - - - - - -

  def major_minor_js(major, minor)
    {
      format: :js,
       major: major,
       minor: minor
    }
  end

end
