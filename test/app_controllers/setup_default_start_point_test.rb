require_relative 'app_controller_test_base'

class SetupDefaultStartPointControllerTest < AppControllerTestBase

  def self.hex_prefix
    '59C'
  end

  # - - - - - - - - - - - - - - - - - - - - - -

  test 'BA2', %w(
  show() lists all language,testFramework and all exercise display_names
  and chooses a random index for both lists ) do
    show
    assert valid_language_index?
    assert valid_exercise_index?
  end

  # - - - - - - - - - - - - - - - - - - - - - -

  test '3D8', %w(
  save_group
  creates a new group at schema.version==1
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
    assert_equal 1, group.schema.version
    assert_equal ruby_rspec,  group.manifest.display_name
    assert_equal leap_years, group.manifest.exercise
    assert_equal [], group.katas
  end

  # - - - - - - - - - - - - - - - - - - - - - -

  test '3D9', %w(
  save_individual
  creates a new individual kata at schema.version==1
  with the given language+test and exercise
  and redirects to kata/edit page ) do
    params = {
      language:ruby_minitest,
      exercise:fizz_buzz
    }
    id = save_individual(params)
    kata = katas[id]
    assert kata.exists?
    assert_equal 1, kata.schema.version
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

    languages.names.each do |display_name|
      assert listed?(display_name)
    end
    exercises.names.each do |exercise_name|
      assert listed?(exercise_name)
    end
  end

  # - - - - - - - - - - - - - - - - - - - - - -

  def save_individual(params)
    get "/#{controller}/save_individual", params:params, as: :html
    assert_response :redirect
    regex = /^(.*)\/kata\/edit\/([0-9A-Za-z]*)$/
    assert m = regex.match(@response.redirect_url)
    m[2] # id
  end

  # - - - - - - - - - - - - - - - - - - - - - -

  def save_group(params)
    get "/#{controller}/save_group", params:params, as: :html
    assert_response :redirect
    regex = /^(.*)\/kata\/group\/([0-9A-Za-z]*)$/
    assert m = regex.match(@response.redirect_url)
    m[2] # id
  end

  # - - - - - - - - - - - - - - - - - - - - - -

  def valid_language_index?
    max = languages.names.size
    (0...max).include?(language_index)
  end

  def language_index
    md = /let selectedLanguage = \$\('#language_' \+ '(\d+)'\);/.match(html)
    refute_nil md
    md[1].to_i
  end

  # - - - - - - - - - - - - - - - - - - - - - -

  def valid_exercise_index?
    max = exercises.names.size
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
    'Fizz Buzz'
  end

  def leap_years
    'Leap Years'
  end

  # - - - - - - - - - - - - - - - - - - - - - -

  def listed?(entry)
    html.include?("data-name=#{quoted(entry)}")
  end

  def quoted(s)
    '"' + s + '"'
  end

end
