#!/bin/bash ../test_wrapper.sh

require_relative './app_controller_test_base'

class SetupControllerTest < AppControllerTestBase

  # Note: going through the rails route into the controller
  #       means a new Dojo object will be created which is
  #       a different Dojo object to the one created in
  #       test/test_domain_helpers.rb
  #       There may be a way to fix/fudge this.
  #       Create a dummy route which leads to a dummy controller method
  #       which inserts the current dojo object into the current Thread's hash.

  test '9F4020',
  'show_languages page shows all language+tests' do
    get 'setup/show_languages'
    assert_response :success

    assert /data-language\=\"#{get_language_from(cpp_assert)}/.match(html), cpp_assert
    assert /data-language\=\"#{get_language_from(asm_assert)}/.match(html), asm_assert
    assert /data-language\=\"#{get_language_from(csharp_nunit)}/.match(html), csharp_nunit
    assert /data-language\=\"#{get_language_from(java_junit)}/.match(html), java_junit

    assert /data-test\=\"#{get_test_from(cpp_assert)}/.match(html), cpp_assert
    assert /data-test\=\"#{get_test_from(asm_assert)}/.match(html), asm_assert
    assert /data-test\=\"#{get_test_from(csharp_nunit)}/.match(html), csharp_nunit
    assert /data-test\=\"#{get_test_from(java_junit)}/.match(html), java_junit
  end

  # - - - - - - - - - - - - - - - - - - - - - -

  test '406596',
  'pull_needed is true if docker image is not already pulled' do
    params = {
      format: :js,
      language: 'C#',
          test: 'Moq'
    }
    get 'setup/pull_needed', params
    assert_response :success
    assert_equal true, json['pull_needed']
  end

  # - - - - - - - - - - - - - - - - - - - - - -

  test 'B28A3D',
  'pull_needed is false if docker image not already pulled' do
    params = {
      format: :js,
      language: 'C#',
          test: 'NUnit'
    }
    get 'setup/pull_needed', params
    assert_response :success
    assert_equal false, json['pull_needed']
  end

  # - - - - - - - - - - - - - - - - - - - - - -

  test 'BB9967',
  'show_instructions page uses cached instructions' do
    get 'setup/show_instructions'
    assert_response :success
    assert /data-exercise\=\"#{print_diamond}/.match(html), print_diamond
    assert /data-exercise\=\"#{roman_numerals}/.match(html), roman_numerals
    assert /data-exercise\=\"#{bowling_game}/.match(html), bowling_game
  end

  # - - - - - - - - - - - - - - - - - - - - - -

  test 'D79BA3',
  'setup/show_languages defaults to language and test-framework of kata',
  'whose full-id is passed in URL (to encourage repetition)' do
    language_display_name = languages_display_names.sample # eg "C++ (g++), CppUTest"
    instructions_name = instructions_names.sample # eg "Word_Wrap"

    id = create_kata(language_display_name, instructions_name)

    get 'setup/show_languages', :id => id
    assert_response :success

    md = /var selectedLanguage = \$\('#language_' \+ (\d+)/.match(html)
    languages_names = languages_display_names.map { |name| get_language_from(name) }.uniq.sort
    selected_language = languages_names[md[1].to_i]

    assert_equal get_language_from(language_display_name), selected_language, 'language'

    # checking the initial test-framework looks to be nigh on impossible on static html
  end

  # - - - - - - - - - - - - - - - - - - - - - -

  test '82562A',
  'setup/show_instructions defaults to instructions of kata',
  'whose full-id is passed in URL (to encourage repetition)' do
    language_display_name = languages_display_names.sample
    instructions_name = instructions_names.sample
    id = create_kata(language_display_name, instructions_name)

    get 'setup/show_instructions', :id => id
    assert_response :success

    md = /var selectedExercise = \$\('#exercise_' \+ (\d+)/.match(html)
    selected_instructions_name = instructions_names[md[1].to_i]
    assert_equal instructions_name, selected_instructions_name, 'instructions'
  end

  # - - - - - - - - - - - - - - - - - - - - - -

  test 'EB77D9',
  'show_exercises page shows all exercises' do
    # This assumes the exercises volume is default-exercises (refactoring)
    assert_equal [
      "Tennis refactoring, C# NUnit",
      "Tennis refactoring, C++ (g++) assert",
      "Tennis refactoring, Java JUnit",
      "Tennis refactoring, Python unitttest",
      "Tennis refactoring, Ruby Test::Unit",
      "Yahtzee refactoring, C# NUnit",
      "Yahtzee refactoring, C++ (g++) assert",
      "Yahtzee refactoring, Java JUnit",
      "Yahtzee refactoring, Python unitttest"
      ],
      exercises_display_names

    get 'setup/show_exercises'
    assert_response :success

    assert /data-language\=\"Tennis refactoring/.match(html)
    assert /data-language\=\"Yahtzee refactoring/.match(html)

    assert /data-test\=\"C# NUnit/.match(html), html

    params = {
      language: 'Tennis refactoring',
      exercise: 'C# NUnit'
    }
    get 'setup/save_exercise', params
    assert_response :success
  end

  # - - - - - - - - - - - - - - - - - - - - - -

  private

  def languages_display_names; languages.map(&:display_name).sort; end
  def instructions_names; instructions.map(&:name).sort; end
  def exercises_display_names; exercises.map(&:display_name).sort; end

  def get_language_from(name); commad(name)[0].strip; end
  def get_test_from(name)    ; commad(name)[1].strip; end
  def commad(s); s.split(','); end

  # - - - - - - - - - - - - - - - - - - - - - -

  def print_diamond ; 'Print_Diamond' ; end
  def roman_numerals; 'Roman_Numerals'; end
  def   bowling_game;   'Bowling_Game'; end

  def cpp_assert;   'C++, assert'; end
  def asm_assert;   'Asm, assert'; end
  def csharp_nunit; 'C#, NUnit'  ; end
  def java_junit;   'Java, JUnit'; end

end
