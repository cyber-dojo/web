require_relative 'app_controller_test_base'

class SetupDefaultStartPointControllerTest < AppControllerTestBase

  def self.hex_prefix
    '59C'
  end

  def hex_setup
    set_starter_class('StarterService')
  end

  # - - - - - - - - - - - - - - - - - - - - - -

  test 'BA2', %w(
  when there is no ID
  show lists all language,testFramework and all exercise display_names
  and chooses a random index for both lists ) do
    show
    assert valid_language_index?
    assert valid_exercise_index?
  end

  # - - - - - - - - - - - - - - - - - - - - - -

  test 'BA3', %w(
  when ID matches a current start-point
  show lists all language,testFramework and all exercise display_names
  and chooses indexes to match the ID
  to encourage repetition ) do
    in_kata { |kata|
      assert_equal ruby_minitest, kata.manifest.display_name
      show({ id: kata.id })
      start_points = starter.language_start_points
      assert_equal ruby_minitest, start_points['languages'][language_index]
      assert_equal fizz_buzz,     start_points['exercises'].keys.sort[exercise_index]
    }
  end

  # - - - - - - - - - - - - - - - - - - - - - -

  test 'BA4', %w(
  when ID does not designate a kata
  show lists all language,testFramework and all exercise display_names
  and chooses a random index for both lists ) do
    show({ id:invalid_id })
    assert valid_language_index?
    assert valid_exercise_index?
  end

  # - - - - - - - - - - - - - - - - - - - - - -

  test 'BA5', %w(
  when ID does not match a current start-point
  show lists all language,testFramework and all exercise display_names
  and chooses a random index for both lists ) do
    manifest = starter.language_manifest(ruby_minitest, fizz_buzz)
    manifest['created'] = time_now
    manifest['display_name'] = 'XXXX'
    manifest['exercise'] = 'YYYY'
    kata = katas.new_kata(manifest)
    show({ id:kata.id })
    assert valid_language_index?
    assert valid_exercise_index?
  end

  # - - - - - - - - - - - - - - - - - - - - - -

  test '3D8', %w(
  save_group
  creates a new group
  with the given display_name
  and does not start any avatars
  and redirects to kata/group page ) do
    params = {
      language:ruby_rspec,
      exercise:leap_years
    }
    gid = save_group(params)
    group = groups[gid]
    assert group.exists?
    assert_equal ruby_rspec,  group.manifest.display_name
    assert_equal leap_years, group.manifest.exercise
    assert_equal [], group.katas
  end

  # - - - - - - - - - - - - - - - - - - - - - -

  test '3D9', %w(
  save_individual
  creates a new individual kata
  with the given language+test and exercise
  and redirects to kata/edit page ) do
    params = {
      language:ruby_minitest,
      exercise:fizz_buzz
    }
    id = save_individual(params)
    kata = katas[id]
    assert kata.exists?
    assert_equal ruby_minitest, kata.manifest.display_name
    assert_equal fizz_buzz, kata.manifest.exercise
    refute kata.group?
  end

  private # = = = = = = = = = = = = = = = = = =

  def controller
    'setup_default_start_point'
  end

  # - - - - - - - - - - - - - - - - - - - - - -

  def show(params = {})
    get "/#{controller}/show", params:params, as: :html
    assert_response :success

    start_points = starter.language_start_points
    start_points['languages'].each do |display_name|
      assert listed?(display_name)
    end
    start_points['exercises'].keys.each do |exercise|
      assert listed?(exercise)
    end
  end

  # - - - - - - - - - - - - - - - - - - - - - -

  def save_individual(params)
    get "/#{controller}/save_individual", params:params, as: :html
    assert_response :redirect
    regex = /^(.*)\/kata\/edit\/([0-9A-Za-z]*)$/
    assert m = regex.match(@response.redirect_url)
    id = m[2]
  end

  # - - - - - - - - - - - - - - - - - - - - - -

  def save_group(params)
    get "/#{controller}/save_group", params:params, as: :html
    assert_response :redirect
    regex = /^(.*)\/kata\/group\/([0-9A-Za-z]*)$/
    assert m = regex.match(@response.redirect_url)
    gid = m[2]
  end

  # - - - - - - - - - - - - - - - - - - - - - -

  def valid_language_index?
    start_points = starter.language_start_points
    max = start_points['languages'].size
    (0...max).include?(language_index)
  end

  def language_index
    md = /let selectedLanguage = \$\('#language_' \+ '(\d+)'\);/.match(html)
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
    md = /let selectedExercise = \$\('#exercise_' \+ '(\d+)'\);/.match(html)
    refute_nil md
    md[1].to_i
  end

  # - - - - - - - - - - - - - - - - - - - - - -

  def ruby_minitest
    'Ruby, MiniTest'
  end

  def ruby_rspec
    'Ruby, RSpec'
  end

  # - - - - - - - - - - - - - - - - - - - - - -

  def fizz_buzz
    'Fizz_Buzz'
  end

  def leap_years
    'Leap_Years'
  end

  # - - - - - - - - - - - - - - - - - - - - - -

  def listed?(entry)
    html.include?("data-name=#{quoted(entry)}")
  end

  def quoted(s)
    '"' + s + '"'
  end

  def invalid_id
    '379C8A'
  end

end
