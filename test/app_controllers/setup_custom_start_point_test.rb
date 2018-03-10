require_relative 'app_controller_test_base'

class SetupCustomStartPointControllerTest < AppControllerTestBase

  def self.hex_prefix
    'EB7634'
  end

  def hex_setup
    set_starter_class('StarterService')
  end

  # - - - - - - - - - - - - - - - - - - - - - -

  test 'BA2', %w(
  when there is no ID
  show lists all custom display_names
  and chooses a random index for it ) do
    show
    assert valid_custom_index?
  end

  # - - - - - - - - - - - - - - - - - - - - - -

  test 'BA3', %w(
  when ID matches a current custom start-point
  show lists all custom display_names
  and chooses an index to match the ID
  to encourage repetition ) do
    create_custom_kata(yahtzee_csharp_nunit)
    show 'id' => kata.id
    start_points = starter.custom_start_points
    assert_equal yahtzee_csharp_nunit, start_points[custom_index]
  end

  # - - - - - - - - - - - - - - - - - - -

  test 'BA4', %w(
  when ID does not designate a kata
  show lists all custom display_names
  and chooses a random index for it ) do
    show 'id' => invalid_id
    assert valid_custom_index?
  end

  # - - - - - - - - - - - - - - - - - - - - - -

  test 'BA5', %w(
  when ID does not match a current custom start-point
  show lists all custom display_names
  and chooses a random index for it ) do
    manifest = starter.custom_manifest(yahtzee_csharp_nunit)
    manifest['id'] = kata_id
    manifest['created'] = time_now
    manifest['display_name'] = 'XXXXX'
    storer.create_kata(manifest)

    show 'id' => manifest['id']
    assert valid_custom_index?
  end

  # - - - - - - - - - - - - - - - - - - - - - -

  test '3D8', %w(
  save_group
  creates a new kata
  with the given display_name
  and does not start any avatars
  and redirects to kata/group page ) do
    display_name = yahtzee_csharp_nunit
    params = { 'display_name' => display_name }
    id = save_group(params)
    kata = katas[id]
    assert_equal display_name,  kata.display_name
    started = kata.avatars.started
    assert_equal 0, started.size
  end

  # - - - - - - - - - - - - - - - - - - - - - -

  test '3D9', %w(
  save_individual
  creates a new kata
  with the given display_name
  and starts a new avatar
  and redirects to kata/individual page ) do
    display_name = yahtzee_python_unittest
    params = { 'display_name' => display_name }
    id,avatar = save_individual(params)
    kata = katas[id]
    assert_equal display_name,  kata.display_name
    started = kata.avatars.started
    assert_equal 1, started.size
    assert_equal [avatar], started.keys
  end

  private # = = = = = = = = = = = = = = = = = =

  def controller
    'setup_custom_start_point'
  end

  def show(params = {})
    get "/#{controller}/show", params:params
    assert_response :success
    starter.custom_start_points.each do |display_name|
      assert listed?(display_name)
    end
  end

  def save_individual(params)
    get "/#{controller}/save_individual", params:params
    assert_response :redirect
    regex = /^(.*)\/kata\/individual\/([0-9A-Z]*)\?avatar=([a-z]*)$/
    assert m = regex.match(@response.redirect_url)
    id = m[2]
    avatar = m[3]
    [id,avatar]
  end

  def save_group(params)
    get "/#{controller}/save_group", params:params
    assert_response :redirect
    regex = /^(.*)\/kata\/group\/([0-9A-Z]*)$/
    assert m = regex.match(@response.redirect_url)
    id = m[2]
  end

  # - - - - - - - - - - - - - - - - - - - - - -

  def valid_custom_index?
    max = starter.custom_start_points.size
    (0...max).include?(custom_index)
  end

  def custom_index
    md = /var selectedCustom = \$\('#custom_' \+ '(\d+)'\);/.match(html)
    refute_nil md
    md[1].to_i
  end

  # - - - - - - - - - - - - - - - - - - - - - -

  def yahtzee_csharp_nunit
    'Yahtzee refactoring, C# NUnit'
  end

  def yahtzee_python_unittest
    'Yahtzee refactoring, Python unitttest'
  end

  # - - - - - - - - - - - - - - - - - - - - - -

  def listed?(entry)
    html.include? "data-name=#{quoted(entry)}"
  end

  def quoted(s)
    '"' + s + '"'
  end

  def invalid_id
    '379C8ABFDF'
  end

end
