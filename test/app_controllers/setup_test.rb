#!/bin/bash ../test_wrapper.sh

require_relative './app_controller_test_base'

class SetupControllerTest < AppControllerTestBase

  test '9F4020',
  'show_languages page uses cached language+tests that are runnable' do
    get 'setup/show_languages'
    assert_response :success
    assert /data-language\=\"#{get_language_from(cpp_assert)}/.match(html), cpp_assert
    assert /data-language\=\"#{get_language_from(asm_assert)}/.match(html), asm_assert
    refute /data-language\=\"Java/.match(html), 'Java'
  end

  # - - - - - - - - - - - - - - - - - - - - - -

  test 'BB9967',
  'show_instructions page uses cached instructions' do
    get 'setup/show_instructions'
    assert_response :success
    assert /data-exercise\=\"#{print_diamond}/.match(html), print_diamond
    assert /data-exercise\=\"#{roman_numerals}/.match(html), roman_numerals
    assert /data-exercise\=\"Bowling_Game/.match(html), bowling_game
  end

  # - - - - - - - - - - - - - - - - - - - - - -

  test 'D79BA3',
  'setup/show_languages defaults to language and instructions of kata',
  'whose full-id is passed in URL (to encourage repetition)' do
    languages_display_names = runner.runnable(languages).map(&:display_name).sort
    language_display_name = languages_display_names.sample
    exercises_names = instructions.map(&:name).sort
    exercise_name = exercises_names.sample
    id = create_kata(language_display_name, exercise_name)

    get 'setup/show_languages', :id => id
    assert_response :success

    # next bit is tricky because language.display_name
    # contains the name of the test framework too.
    md = /var selectedLanguage = \$\('#language_' \+ (\d+)/.match(html)
    languages_names = languages_display_names.map { |name| get_language_from(name) }.uniq.sort
    selected_language = languages_names[md[1].to_i]
    assert_equal get_language_from(language_display_name), selected_language, 'language'
  end

  # - - - - - - - - - - - - - - - - - - - - - -

  test '82562A',
  'setup/show_instructions defaults to instructions of kata',
  'whose full-id is passed in URL (to encourage repetition)' do
    languages_display_names = runner.runnable(languages).map(&:display_name).sort
    language_display_name = languages_display_names.sample
    instructions_names = instructions.map(&:name).sort
    instructions_name = instructions_names.sample
    id = create_kata(language_display_name, instructions_name)

    get 'setup/show_instructions', :id => id
    assert_response :success

    md = /var selectedExercise = \$\('#exercise_' \+ (\d+)/.match(html)
    selected_instructions_name = instructions_names[md[1].to_i]
    assert_equal instructions_name, selected_instructions_name, 'instructions'
  end

  # - - - - - - - - - - - - - - - - - - - - - -

  private

  def get_language_from(name); commad(name)[0].strip; end
  def get_test_from(name)    ; commad(name)[1].strip; end
  def commad(s); s.split(','); end

  # - - - - - - - - - - - - - - - - - - - - - -

  def print_diamond ; 'Print_Diamond' ; end
  def roman_numerals; 'Roman_Numerals'; end
  def   bowling_game;   'Bowling_Game'; end

  def cpp_assert; 'C++, assert'; end
  def asm_assert; 'Asm, assert'; end

end
