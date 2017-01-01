require_relative 'app_controller_test_base'

class SetupDefaultStartPointControllerTest < AppControllerTestBase

  def setup_runner_class
    set_runner_class('StubRunner')
  end

  def prepare
    set_storer_class('FakeStorer')
  end

  test '9F4020',
  'show_languages page shows all language+tests' do
    prepare
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

  test 'BB9967',
  'show_exercises page uses cached exercises' do
    prepare
    do_get 'show_exercises'
    assert /data-name\=\"#{print_diamond}/.match(html),  print_diamond
    assert /data-name\=\"#{roman_numerals}/.match(html), roman_numerals
    assert /data-name\=\"#{bowling_game}/.match(html),   bowling_game
  end

  # - - - - - - - - - - - - - - - - - - - - - -

  test '7433D8',
  'save creates a new kata with language+test and exercise' do
    prepare
    params = {
         'major' => 'C#',
         'minor' => 'Moq',
      'exercise' => print_diamond
    }
    do_get 'save', params
    kata = katas[json['id']]
    assert_equal 'C#-Moq', kata.language
    assert_equal 'Print_Diamond', kata.exercise
  end

  # - - - - - - - - - - - - - - - - - - - - - -

  test 'D79BA3',
  'show_languages defaults to language and test-framework of kata',
  'whose full-id is passed in URL (to encourage repetition)' do
    prepare
    language_display_name = languages_display_names.sample # eg "C++ (g++), CppUTest"
    exercise_name = exercises_names.sample # eg "Word_Wrap"
    id = create_kata(language_display_name, exercise_name)

    do_get 'show_languages', 'id' => id

    md = /var selectedMajor = \$\('#major_' \+ (\d+)/.match(html)
    refute_nil md
    languages_names = languages_display_names.map { |name| get_language_from(name) }.uniq.sort
    selected_language = languages_names[md[1].to_i]
    assert_equal get_language_from(language_display_name), selected_language, 'language'
    # checking the initial test-framework looks to be nigh on impossible on static html
  end

  # - - - - - - - - - - - - - - - - - - - - - -

  test '82562A',
  'show_exercises defaults to exercise of kata',
  'whose full-id is passed in URL (to encourage repetition)' do
    prepare
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

  def cpp_assert;   'C++, assert'; end
  def asm_assert;   'Asm, assert'; end
  def csharp_nunit; 'C#, NUnit'  ; end
  def java_junit;   'Java, JUnit'; end

end
