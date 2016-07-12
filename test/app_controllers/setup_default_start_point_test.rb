#!/bin/bash ../test_wrapper.sh

require_relative './app_controller_test_base'

class SetupDefaultStartPointControllerTest < AppControllerTestBase

  test '9F4020',
  'show_languages page shows all language+tests' do
    do_get 'show_languages'

    assert /data-major\=\"#{get_language_from(cpp_assert)}/.match(html), cpp_assert
    assert /data-major\=\"#{get_language_from(asm_assert)}/.match(html), asm_assert
    assert /data-major\=\"#{get_language_from(csharp_nunit)}/.match(html), csharp_nunit
    assert /data-major\=\"#{get_language_from(java_junit)}/.match(html), java_junit

    assert /data-minor\=\"#{get_test_from(cpp_assert)}/.match(html), cpp_assert
    assert /data-minor\=\"#{get_test_from(asm_assert)}/.match(html), asm_assert
    assert /data-minor\=\"#{get_test_from(csharp_nunit)}/.match(html), csharp_nunit
    assert /data-minor\=\"#{get_test_from(java_junit)}/.match(html), java_junit
  end

  # - - - - - - - - - - - - - - - - - - - - - -

  test '406596',
  'pull_needed is true if docker image is not pulled' do
    do_get 'pull_needed', major_minor_js('C#', 'Moq')
    assert json['pull_needed']
  end

  # - - - - - - - - - - - - - - - - - - - - - -

  test 'B28A3D',
  'pull_needed is false if docker image is pulled' do
    do_get 'pull_needed', major_minor_js('C#', 'NUnit')
    refute json['pull_needed']
  end

  # - - - - - - - - - - - - - - - - - - - - - -

  test '0A8080',
  'pull issues docker-pull command for appropriate image_name' do
    setup_mock_shell
    shell.mock_exec(
      ['docker pull cyberdojofoundation/csharp_nunit'],
      docker_pull_output,
      exit_success
    )
    do_get 'pull', major_minor_js('C#', 'NUnit')
    shell.teardown
  end

  # - - - - - - - - - - - - - - - - - - - - - -

  test 'BB9967',
  'show_instructions page uses cached instructions' do
    do_get 'show_instructions'
    assert /data-name\=\"#{print_diamond}/.match(html), print_diamond
    assert /data-name\=\"#{roman_numerals}/.match(html), roman_numerals
    assert /data-name\=\"#{bowling_game}/.match(html), bowling_game
  end

  # - - - - - - - - - - - - - - - - - - - - - -

  test 'D79BA3',
  'show_languages defaults to language and test-framework of kata',
  'whose full-id is passed in URL (to encourage repetition)' do
    language_display_name = languages_display_names.sample # eg "C++ (g++), CppUTest"
    instructions_name = instructions_names.sample # eg "Word_Wrap"
    id = create_kata(language_display_name, instructions_name)

    do_get 'show_languages', :id => id

    md = /var selectedMajor = \$\('#major_' \+ (\d+)/.match(html)
    refute_nil md
    languages_names = languages_display_names.map { |name| get_language_from(name) }.uniq.sort
    selected_language = languages_names[md[1].to_i]
    assert_equal get_language_from(language_display_name), selected_language, 'language'
    # checking the initial test-framework looks to be nigh on impossible on static html
  end

  # - - - - - - - - - - - - - - - - - - - - - -

  test '82562A',
  'show_instructions defaults to instructions of kata',
  'whose full-id is passed in URL (to encourage repetition)' do
    language_display_name = languages_display_names.sample
    instructions_name = instructions_names.sample
    id = create_kata(language_display_name, instructions_name)

    do_get 'show_instructions', :id => id

    md = /var selected = \$\('#instructions_name_' \+ (\d+)/.match(html)
    selected_instructions_name = instructions_names[md[1].to_i]
    assert_equal instructions_name, selected_instructions_name, 'instructions'
  end

  # - - - - - - - - - - - - - - - - - - - - - -

  private

  def do_get(route, params = {})
    controller = 'setup_default_start_point'
    get "#{controller}/#{route}", params
    assert_response :success
  end

  # - - - - - - - - - - - - - - - - - - - - - -

  def languages_display_names; languages.map(&:display_name).sort; end
  def instructions_names; instructions.map(&:name).sort; end

  # - - - - - - - - - - - - - - - - - - - - - -

  def get_language_from(name); commad(name)[0].strip; end
  def get_test_from(name)    ; commad(name)[1].strip; end
  def commad(s); s.split(','); end

  # - - - - - - - - - - - - - - - - - - - - - -

  def print_diamond ; 'Print_Diamond' ; end
  def roman_numerals; 'Roman_Numerals'; end
  def   bowling_game;   'Bowling_Game'; end

  # - - - - - - - - - - - - - - - - - - - - - -

  def cpp_assert;   'C++, assert'; end
  def asm_assert;   'Asm, assert'; end
  def csharp_nunit; 'C#, NUnit'  ; end
  def java_junit;   'Java, JUnit'; end

  # - - - - - - - - - - - - - - - - - - - - - -

  def major_minor_js(major, minor)
    {
      format: :js,
       major: major,
       minor: minor
    }
  end

end
