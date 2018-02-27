require_relative 'app_controller_test_base'

class SetupDefaultStartPointControllerTest < AppControllerTestBase

  def self.hex_prefix
    '59C9F4'
  end

  def hex_setup
    set_starter_class('StarterService')
  end

  # - - - - - - - - - - - - - - - - - - - - - -

  test '020',
  'show displays language,testFramework list and exercise list' do
    do_get 'show'
    assert listed?(ruby_minitest)
    assert listed?(ruby_rspec)
    assert valid_language_index?

    assert listed?(bowling_game)
    assert listed?(fizz_buzz)
    assert listed?(leap_years)
    assert listed?(tiny_maze)
    assert valid_exercise_index?
  end

  # - - - - - - - - - - - - - - - - - - - - - -

  test 'BA3',
  'show defaults to language,test-framework and exercise of kata',
  'whose full-id is passed in URL (to encourage repetition)' do
    in_kata(:stateless) {}
    assert_equal ruby_minitest, kata.display_name
    do_get 'show', 'id' => kata.id

    start_points = starter.language_start_points
    assert_equal ruby_minitest, start_points['languages'][language_index]
    assert_equal fizz_buzz,     start_points['exercises'].keys.sort[exercise_index]
  end

  # - - - - - - - - - - - - - - - - - - - - - -

  test 'BA4',
  'show ok when display_name of full-id passed in URL not a current start-point' do
    manifest = starter.language_manifest(ruby_minitest, 'Fizz_Buzz')
    manifest['id'] = kata_id
    manifest['created'] = time_now
    manifest['display_name'] = 'Wuby, MiniTest'
    manifest['exercise'] = 'Fizzy_Buzzy'
    storer.create_kata(manifest)

    do_get 'show', 'id' => manifest['id']
    assert valid_language_index?
    assert valid_exercise_index?
  end

  # - - - - - - - - - - - - - - - - - - - - - -

  test '565',
  'show ok when kata_id is invalid' do
    do_get 'show', 'id' => '379C8ABFDF'

    assert listed?(ruby_minitest)
    assert listed?(ruby_rspec)
    assert valid_language_index?

    assert listed?(bowling_game)
    assert listed?(fizz_buzz)
    assert listed?(leap_years)
    assert listed?(tiny_maze)
    assert valid_exercise_index?
  end

  # - - - - - - - - - - - - - - - - - - - - - -

  test '3D8', %w(
  save_group creates a new kata with language+test and exercise
  and redirects to kata/group page ) do
    params = {
      'language' => ruby_minitest,
      'exercise' => fizz_buzz
    }
    do_get 'save_group', params
    assert_response :redirect
    #@response.redirect_url
    #http://www.example.com/kata/group/BC8E8A6433
    regex = /^http:\/\/www\.example\.com\/kata\/group\/([0-9A-Z]*)$/
    assert m = regex.match(@response.redirect_url)
    id = m[1]
    kata = katas[id]
    assert_equal ruby_minitest,  kata.display_name
    assert_equal fizz_buzz, kata.exercise
  end

  # - - - - - - - - - - - - - - - - - - - - - -

  # TODO: save_individual

  private # = = = = = = = = = = = = = = = = = =

  def do_get(route, params = {})
    controller = 'setup_default_start_point'
    get "/#{controller}/#{route}", params:params
  end

  # - - - - - - - - - - - - - - - - - - - - - -

  def valid_language_index?
    start_points = starter.language_start_points
    max = start_points['languages'].size
    (0...max).include?(language_index)
  end

  def language_index
    md = /var selectedLanguage = \$\('#language_' \+ '(\d+)'\);/.match(html)
    refute_nil md
    md[1].to_i
  end

  # - - - - - - - - - - - - - - - - - - - - - -

  def valid_exercise_index?
    start_points = starter.language_start_points
    max = start_points['exercises'].size
    (0...max).include?(exercise_index)
  end

  def exercise_index
    md = /var selectedExercise = \$\('#exercise_' \+ '(\d+)'\);/.match(html)
    refute_nil md
    md[1].to_i
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

  def ruby_minitest
    'Ruby, MiniTest'
  end

  def ruby_rspec
    'Ruby, RSpec'
  end

  # - - - - - - - - - - - - - - - - - - - - - -

  def listed?(entry)
    html.include? "data-name=#{quoted(entry)}"
  end

  def quoted(s)
    '"' + s + '"'
  end

end
