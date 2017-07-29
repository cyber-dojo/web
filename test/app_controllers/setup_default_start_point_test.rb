require_relative 'app_controller_test_base'

class SetupDefaultStartPointControllerTest < AppControllerTestBase

  test '59C9F4020',
  'show_languages page shows language+tests (smoke)' do
    do_get 'show_languages'
    assert html.include? "data-major=#{quoted(get_language_from(c_assert))}"
    assert html.include? "data-minor=#{quoted(get_test_from(c_assert))}"
    assert html.include? "data-major=#{quoted(get_language_from(ruby_testunit))}"
    assert html.include? "data-minor=#{quoted(get_test_from(ruby_testunit))}"
  end

  # - - - - - - - - - - - - - - - - - - - - - -

  test '59CBB9967',
  'show_exercises page uses cached exercises (smoke)' do
    do_get 'show_exercises'
    assert html.include? "data-name=#{quoted(print_diamond)}"
    assert html.include? "data-name=#{quoted(roman_numerals)}"
    assert html.include? "data-name=#{quoted(bowling_game)}"
  end

  # - - - - - - - - - - - - - - - - - - - - - -

  test '59C7433D8',
  'save creates a new kata with language+test and exercise' do
    params = {
         'major' => get_language_from(c_assert),
         'minor' => get_test_from(c_assert),
      'exercise' => print_diamond
    }
    do_get 'save', params
    kata = katas[json['id']]
    assert_equal 'C (gcc)-assert', kata.language  # comma -> hyphen
    assert_equal print_diamond, kata.exercise
  end

  # - - - - - - - - - - - - - - - - - - - - - -

  test '59CD79BA3',
  'show_languages defaults to language and test-framework of kata',
  'whose full-id is passed in URL (to encourage repetition)' do
    language_display_name = languages_display_names.sample # eg "C++ (g++), CppUTest"
    exercise_name = exercises_names.sample # eg "Word_Wrap"
    id = create_kata(language_display_name, exercise_name)

    do_get 'show_languages', 'id' => id

    md = /var selectedMajor = \$\('#major_' \+ (\d+)/.match(html)
    refute_nil md
    languages_names = languages_display_names.map { |name| get_language_from(name) }.uniq.sort
    selected_language = languages_names[md[1].to_i]
    assert_equal get_language_from(language_display_name), selected_language, 'language'
    # checking the initial test-framework looks to be
    # nigh on impossible in static html
  end

  # - - - - - - - - - - - - - - - - - - - - - -

  test '59C82562A',
  'show_exercises defaults to exercise of kata',
  'whose full-id is passed in URL (to encourage repetition)' do
    language_display_name = languages_display_names.sample
    exercise_name = exercises_names.sample
    id = create_kata(language_display_name, exercise_name)

    do_get 'show_exercises', 'id' => id

    md = /var selected = \$\('#exercises_name_' \+ (\d+)/.match(html)
    selected_exercise_name = exercises_names[md[1].to_i]
    assert_equal exercise_name, selected_exercise_name, 'exercises'
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
  def exercises_names; exercises.map(&:name).sort; end

  # - - - - - - - - - - - - - - - - - - - - - -

  def get_language_from(name); commad(name)[0].strip; end
  def get_test_from(name)    ; commad(name)[1].strip; end
  def commad(s); s.split(','); end

  # - - - - - - - - - - - - - - - - - - - - - -

  def print_diamond ; 'Print_Diamond' ; end
  def roman_numerals; 'Roman_Numerals'; end
  def   bowling_game;   'Bowling_Game'; end

  # - - - - - - - - - - - - - - - - - - - - - -

  def c_assert;      'C (gcc), assert'; end
  def ruby_testunit; 'Ruby, Test::Unit'; end

  def quoted(s); '"' + s + '"'; end

end
