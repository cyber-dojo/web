require_relative 'app_controller_test_base'

class SetupCustomStartPointControllerTest < AppControllerTestBase

  def self.hex_prefix
    'EB7'
  end

  def hex_setup
    set_custom_class('CustomService')
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

=begin
  test 'BA3', %w(
  when ID matches a current custom start-point
  show lists all custom display_names
  and chooses an index to match the ID
  to encourage repetition ) do
    create_custom_kata(yahtzee_csharp_nunit)
    show({ id:@id })
    start_points = starter.custom_start_points
    assert_equal yahtzee_csharp_nunit, start_points[custom_index]
  end
=end

  # - - - - - - - - - - - - - - - - - - -

  test 'BA4', %w(
  when ID does not designate a kata or a group
  show lists all custom display_names
  and chooses a random index for it ) do
    show({ id:invalid_id })
    assert valid_custom_index?
  end

  # - - - - - - - - - - - - - - - - - - - - - -

  test 'BA5', %w(
  when ID does not match a current custom start-point
  show lists all custom display_names
  and chooses a random index for it ) do
    manifest = custom.manifest(yahtzee_csharp_nunit)
    manifest['created'] = time_now
    manifest['display_name'] = 'XXXXX'
    group = groups.new_group(manifest)
    show({ id:group.id })
    assert valid_custom_index?
  end

  # - - - - - - - - - - - - - - - - - - - - - -

  test '3D8', %w(
  save_group
  creates a new group
  with the given display_name
  and does not start any avatars
  and redirects to kata/group page ) do
    params = { display_name:yahtzee_csharp_nunit }
    gid = save_group(params)
    group = groups[gid]
    assert group.exists?
    assert_equal yahtzee_csharp_nunit,  group.manifest.display_name
    assert_equal [], group.katas
  end

  # - - - - - - - - - - - - - - - - - - - - - -

  test '3D9', %w(
  save_individual
  creates a new individual kata
  with the given display_name
  and redirects to kata/edit page ) do
    params = { display_name:yahtzee_python_unittest }
    id = save_individual(params)
    kata = katas[id]
    assert kata.exists?
    assert_equal yahtzee_python_unittest,  kata.manifest.display_name
    refute kata.group?
  end

  private # = = = = = = = = = = = = = = = = = =

  def controller
    'setup_custom_start_point'
  end

  def show(params = {})
    get "/#{controller}/show", params:params, as: :html
    assert_response :success
    custom.names.each do |display_name|
      assert listed?(display_name)
    end
  end

  def save_individual(params)
    get "/#{controller}/save_individual", params:params, as: :html
    assert_response :redirect
    regex = /^(.*)\/kata\/edit\/([0-9A-Za-z]*)$/
    assert m = regex.match(@response.redirect_url)
    id = m[2]
  end

  def save_group(params)
    get "/#{controller}/save_group", params:params, as: :html
    assert_response :redirect
    regex = /^(.*)\/kata\/group\/([0-9A-Za-z]*)$/
    assert m = regex.match(@response.redirect_url)
    id = m[2]
  end

  # - - - - - - - - - - - - - - - - - - - - - -

  def valid_custom_index?
    max = custom.names.size
    (0...max).include?(custom_index)
  end

  def custom_index
    md = /let selectedCustom = \$\('#custom_' \+ '(\d+)'\);/.match(html)
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
    '379C8A'
  end

end
