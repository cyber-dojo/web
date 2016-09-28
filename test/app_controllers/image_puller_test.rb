#!/bin/bash ../test_wrapper.sh

require_relative './app_controller_test_base'

class ImagePullerTest < AppControllerTestBase

  def setup_id(hex)
    @test_id = hex
  end

  def setup_mock_shell
    ENV['CYBER_DOJO_TEST_ID'] = @test_id
    set_shell_class('MockHostShell')
  end

  # Note: AppControllerTestBase sets StubRunner
  # which assumes the current state of [docker images] to be
  #    cyberdojofoundation/nasm_assert
  #    cyberdojofoundation/gcc_assert
  #    cyberdojofoundation/csharp_nunit
  #    cyberdojofoundation/gpp_cpputest

  # - - - - - - - - - - - - - - - - - - - - - -
  # from Language+Test setup page
  # - - - - - - - - - - - - - - - - - - - - - -

  test '406596',
  'language pull.needed is true when docker image is not pulled' do
    do_get 'pull_needed', major_minor_js('language', 'C#', 'Moq')
    assert json['needed']
  end

  # - - - - - - - - - - - - - - - - - - - - - -

  test 'B28A3D',
  'language pull.needed is false when docker image is pulled' do
    do_get 'pull_needed', major_minor_js('language', 'C#', 'NUnit')
    refute json['needed']
  end

  # - - - - - - - - - - - - - - - - - - - - - -

  test '0A8080',
  'language pull issues docker-pull image_name command',
  'and returns succeeded=true when pull succeeds' do
    setup_mock_shell
    mock_docker_pull_success('csharp_nunit')
    do_get 'pull', major_minor_js('language', 'C#', 'NUnit')
    assert json['succeeded']
    shell.teardown
  end

  # - - - - - - - - - - - - - - - - - - - - - -

  test '4DB3FD',
  'language pull issues docker-pull image_name command',
  'and returns succeeded=false when pull fails' do
    setup_mock_shell
    mock_docker_pull_failure('csharp_nunit')
    do_get 'pull', major_minor_js('language', 'C#', 'NUnit')
    refute json['succeeded']
    shell.teardown
  end

  # - - - - - - - - - - - - - - - - - - - - - -
  # from Custom setup page
  # - - - - - - - - - - - - - - - - - - - - - -

  test '294C10',
  'custom pull.needed is true when docker image is not pulled' do
    do_get 'pull_needed', major_minor_js('custom', 'Tennis refactoring', 'Python unitttest')
    assert json['needed']
  end

  # - - - - - - - - - - - - - - - - - - - - - -

  test '9D3E9A',
  'custom pull_needed is false when docker image is pulled' do
    do_get 'pull_needed', major_minor_js('custom', 'Tennis refactoring', 'C# NUnit')
    refute json['needed']
  end

  # - - - - - - - - - - - - - - - - - - - - - -

  test '4694A0',
  'custom pull issues docker-pull image_name command',
  'and returns succeeded=true when pull succeeds' do
    setup_mock_shell
    mock_docker_pull_success('python_unittest')
    do_get 'pull', major_minor_js('custom', 'Tennis refactoring', 'Python unitttest')
    assert json['succeeded']
    shell.teardown
  end

  # - - - - - - - - - - - - - - - - - - - - - -

  test '05C5E7',
  'custom pull issues docker-pull image_name command',
  'and returns succeeded=false when pull fails' do
    setup_mock_shell
    mock_docker_pull_failure('python_unittest')
    do_get 'pull', major_minor_js('custom', 'Tennis refactoring', 'Python unitttest')
    refute json['succeeded']
    shell.teardown
  end

  # - - - - - - - - - - - - - - - - - - - - - -
  # from Fork on review page/dialog
  # - - - - - - - - - - - - - - - - - - - - - -

  test '6F2269',
  'kata pull.needed is false when image (from post start-point re-architecture)',
  'kata.id has already been pulled' do
    create_kata('C#, NUnit')
    do_get 'pull_needed', id_js
    refute json['needed']
  end

  # - - - - - - - - - - - - - - - - - - - - - -

  test 'A9FA97',
  'kata pull.needed is true when image (from post start-point re-architecture)',
  'kata.id has not been pulled' do
    create_kata('C#, Moq')
    do_get 'pull_needed', id_js
    assert json['needed']
  end

  # - - - - - - - - - - - - - - - - - - - - - -

  test '317E66',
  'kata pull issues docker-pull image_name command',
  'and returns succeeded=true when pull succeeds' do
    create_kata('C#, Moq')
    mock_docker_pull_success('csharp_moq')
    do_get 'pull', id_js
    assert json['succeeded']
    shell.teardown
  end

  # - - - - - - - - - - - - - - - - - - - - - -

  test 'B45B07',
  'kata pull issues docker-pull image_name command',
  'and returns succeeded=false when pull fails' do
    create_kata('C#, Moq')
    mock_docker_pull_failure('csharp_moq')
    do_get 'pull', id_js
    refute json['succeeded']
    shell.teardown
  end

  private

  def mock_docker_pull_failure(image_name)
    setup_mock_shell
    shell.mock_exec(
      ["docker pull cyberdojofoundation/#{image_name}"],
      any_output='456ersfdg',
      exit_failure=34
    )
  end

  # - - - - - - - - - - - - - - - - - - - - - -

  def mock_docker_pull_success(image_name)
    setup_mock_shell
    shell.mock_exec(
      ["docker pull cyberdojofoundation/#{image_name}"],
      docker_pull_output,
      exit_success
    )
  end

  # - - - - - - - - - - - - - - - - - - - - - -

  def do_get(route, params = {})
    controller = 'image_puller'
    get "#{controller}/#{route}", params
    assert_response :success
  end

  # - - - - - - - - - - - - - - - - - - - - - -

  def major_minor_js(type, major, minor)
    {
      format: :js,
        type: type,
       major: major,
       minor: minor
    }
  end

  # - - - - - - - - - - - - - - - - - - - - - -

  def id_js
    {
        type: :kata,
      format: :js,
          id: @id
    }
  end

end
