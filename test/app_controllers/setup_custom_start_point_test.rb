require_relative 'app_controller_test_base'

class SetupCustomStartPointControllerTest < AppControllerTestBase

  def self.hex_prefix
    'EB7'
  end

  # - - - - - - - - - - - - - - - - - - - - - -

  test 'BA2', %w(
  show lists all custom display_names
  and chooses a random index for it ) do
    show
    assert valid_custom_index?
  end

  # - - - - - - - - - - - - - - - - - - - - - -

  test '3D8', %w(
  save_group
  creates a new group at schema.version==1
  with the given display_name
  and does not start any avatars
  and redirects to kata/group page ) do
    params = { display_name:yahtzee_csharp_nunit }
    gid = save_group(params)
    group = groups[gid]
    assert group.exists?
    assert_equal 1, group.schema.version
    assert_equal yahtzee_csharp_nunit,  group.manifest.display_name
    assert_equal [], group.katas
  end

  # - - - - - - - - - - - - - - - - - - - - - -

  test '3D9', %w(
  save_individual
  creates a new individual kata at schema.version==1
  with the given display_name
  and redirects to kata/edit page ) do
    params = { display_name:yahtzee_python_unittest }
    id = save_individual(params)
    kata = katas[id]
    assert kata.exists?
    assert_equal 1, kata.schema.version
    assert_equal yahtzee_python_unittest,  kata.manifest.display_name
    refute kata.group?
  end

  # - - - - - - - - - - - - - - - - - - - - - -

  test 'DDD', %w(
  format=html
  save_individual with display_name in URL
  creates new individual session and redirects to it
  ) do
    get individual_url_params, as: :html
    assert_response :redirect
    #http://.../kata/edit/6433rG
    regex = /^(.*)\/kata\/edit\/([0-9A-Za-z]*)$/
    assert m = regex.match(@response.redirect_url)
    id = m[2]
    kata = katas[id]
    assert kata.exists?
  end

  # - - - - - - - - - - - - - - - - - - - - - -

  test 'DDE', %w(
  format=html
  save_group with display_name in URL
  creates new group session and redirects to it
  ) do
    get group_url_params, as: :html
    assert_response :redirect
    #http://.../kata/group/6433rG
    regex = /^(.*)\/kata\/group\/([0-9A-Za-z]*)$/
    assert m = regex.match(@response.redirect_url)
    id = m[2]
    group = groups[id]
    assert group.exists?
  end

  # - - - - - - - - - - - - - - - - - - - - - -

  test '933', %w(
  format=json
  save_individual with display_name in URL
  creates new individual session and returns its id in json response
  ) do
    get individual_url_params, as: :json
    assert_response :success
    id = json['id']
    kata = katas[id]
    assert kata.exists?
  end

  # - - - - - - - - - - - - - - - - - - - - - -

  test '934', %w(
  format=json
  save_group with display_name in URL
  creates new group session and returns its id in json response
  ) do
    get group_url_params, as: :json
    assert_response :success
    id = json['id']
    group = groups[id]
    assert group.exists?
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
    m[2] # id
  end

  def save_group(params)
    get "/#{controller}/save_group", params:params, as: :html
    assert_response :redirect
    regex = /^(.*)\/kata\/group\/([0-9A-Za-z]*)$/
    assert m = regex.match(@response.redirect_url)
    m[2] # id
  end

  # - - - - - - - - - - - - - - - - - - - - - -

  def individual_url_params
    "/#{controller}/save_individual?#{url_params}"
  end

  def group_url_params
    "/#{controller}/save_group?#{url_params}"
  end

  def url_params
    display_name = url_encoded(yahtzee_csharp_nunit)
    "display_name=#{display_name}"
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

end
