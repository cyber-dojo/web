require_relative 'app_controller_test_base'

class SetupDefaultStartPointControllerTest < AppControllerTestBase

  test '59C9F4020',
  'show_languages page' do
    do_get 'show_languages'
    assert html.include? "data-major=#{quoted(get_language_from(c_assert))}"
    assert html.include? "data-minor=#{quoted(get_test_from(c_assert))}"
    assert html.include? "data-major=#{quoted(get_language_from(python_unittest))}"
    assert html.include? "data-minor=#{quoted(get_test_from(python_unittest))}"
  end

  # - - - - - - - - - - - - - - - - - - - - - -

  test '59C271565',
  'show_languages when kata_id is invalid' do
    do_get 'show_languages', 'id' => '379C8ABFDF'
    assert html.include? "data-major=#{quoted(get_language_from(c_assert))}"
    assert html.include? "data-minor=#{quoted(get_test_from(c_assert))}"
    assert html.include? "data-major=#{quoted(get_language_from(python_unittest))}"
    assert html.include? "data-minor=#{quoted(get_test_from(python_unittest))}"
  end

  # - - - - - - - - - - - - - - - - - - - - - -

  test '59CBB9967',
  'show_exercises page' do
    do_get 'show_exercises'
    assert html.include? "data-name=#{quoted(bowling_game)}"
    assert html.include? "data-name=#{quoted(fizz_buzz)}"
    assert html.include? "data-name=#{quoted(leap_years)}"
    assert html.include? "data-name=#{quoted(tiny_maze)}"
  end

  # - - - - - - - - - - - - - - - - - - - - - -

  test '59C7433D8',
  'save creates a new kata with language+test and exercise' do
    params = {
         'major' => get_language_from(c_assert),
         'minor' => get_test_from(c_assert),
      'exercise' => fizz_buzz
    }
    do_get 'save', params
    kata = katas[json['id']]
    assert_equal 'C (gcc)-assert', kata.language
    assert_equal 'C (gcc), assert', kata.display_name
    assert_equal fizz_buzz, kata.exercise
  end

  # - - - - - - - - - - - - - - - - - - - - - -

  test '59CD79BA3',
  'show_languages defaults to language and test-framework of kata',
  'whose full-id is passed in URL (to encourage repetition)' do
    id = create_kata('C (gcc), assert', 'Fizz_Buzz')
    do_get 'show_languages', 'id' => id
    choices = starter.languages_choices(nil)
    major_names = choices['major_names']
    md = /var selectedMajor = \$\('#major_' \+ (\d+)/.match(html)
    refute_nil md
    assert_equal 'C (gcc)', major_names[md[1].to_i]
    # checking the initial test-framework looks to be
    # nigh on impossible in static html
  end

  test '59CD79BA4',
  'deliberate fail to prevent Travis building new image yet' do
    fail
  end

  # - - - - - - - - - - - - - - - - - - - - - -

  test '59C82562A',
  'show_exercises defaults to exercise of kata',
  'whose full-id is passed in URL (to encourage repetition)' do
    choices = starter.exercises_choices(nil)
    exercises_names = choices['names']
    exercises_names.each_with_index do |exercise_name,index|
      id = create_kata('C (gcc), assert', exercise_name)
      do_get 'show_exercises', 'id' => id
      md = /var selected = \$\('#exercises_name_' \+ (\d+)/.match(html)
      assert_equal index, md[1].to_i
    end
  end

  # - - - - - - - - - - - - - - - - - - - - - -

  private

  def do_get(route, params = {})
    controller = 'setup_default_start_point'
    get "#{controller}/#{route}", params
    assert_response :success
  end

  # - - - - - - - - - - - - - - - - - - - - - -

  def get_language_from(name)
    commad(name)[0].strip
  end

  def get_test_from(name)
    commad(name)[1].strip
  end

  def commad(s)
    s.split(',')
  end

  # - - - - - - - - - - - - - - - - - - - - - -

  def bowling_game
    'Bowling_Game'
  end

  def fizz_buzz
    'Fizz_Buzz'
  end

  def leap_years
    'Leap_Years'
  end

  def tiny_maze
    'Tiny_Maze'
  end

  # - - - - - - - - - - - - - - - - - - - - - -

  def c_assert
    'C (gcc), assert'
  end

  def python_unittest
    'Python, unittest'
  end

  def quoted(s)
    '"' + s + '"'
  end

end
