require_relative './app_controller_test_base'

class MockRunner

  @@pulled = []
  @@pull = []
  @@new_kata = []

  def initialize(_parent)
  end

  def teardown
    error   "@@pulled != []:#{@@pulled}"   unless @@pulled   == []
    error     "@@pull != []:#{@@pull}"     unless @@pull     == []
    error "@@new_kata != []:#{@@new_kata}" unless @@new_kata == []
  end

  def mock_pulled?(image_name, kata_id, result)
    @@pulled << [image_name, kata_id, result]
  end

  def pulled?(image_name, kata_id)
    error "no mock for pulled?(#{image_name})" if @@pulled == []
    mock = @@pulled.shift
    error "expected:#{mock[0]}, actual:#{image_name}:" unless mock[0] == image_name
    error "expected:#{mock[1]}, actual:#{kata_id}:"    unless mock[1] == kata_id
    mock[2]
  end

  # - - - - - - - - - - - - - - - - - - - -

  def mock_pull(image_name, kata_id, result)
    @@pull << [image_name, kata_id, result]
  end

  def pull(image_name, kata_id)
    error "no mock for pull(#{image_name})" if @@pull == []
    mock = @@pull.shift
    error "expected:#{mock[0]}, actual:#{image_name}:" unless mock[0] == image_name
    error "expected:#{mock[1]}, actual:#{kata_id}:"    unless mock[1] == kata_id
    mock[2]
  end

  # - - - - - - - - - - - - - - - - - - - -

  def mock_new_kata(image_name, kata_id)
    @@new_kata << [image_name, kata_id]
  end

  def new_kata(image_name, kata_id)
    error "no mock for new_kata(#{image_name},#{kata_id})" if @@new_kata == []
    mock = @@new_kata.shift
    error "expected:#{mock[0]}, actual:#{image_name}:" unless mock[0] == image_name
    error "expected:#{mock[1]}, actual:#{kata_id}:"    unless mock[1] == kata_id
  end

  private

  def error(message)
    fail "MockRunner:#{message}"
  end

end

# = = = = = = = = = = = = = = = = = = = = = = =

class ImagePullerTest < AppControllerTestBase

  # - - - - - - - - - - - - - - - - - - - - - -
  # from Language+Test setup page
  # - - - - - - - - - - - - - - - - - - - - - -

  test '406596',
  'pulled? succeeds with true/false' do
    set_runner_class('MockRunner')
    image_name = "#{cdf}/csharp_moq"
    kata_id = '4065965FB2'

    runner.mock_pulled?(image_name, kata_id, true)
    do_get 'pulled', js(image_name, kata_id)
    assert json['result']

    runner.mock_pulled?(image_name, kata_id, false)
    do_get 'pulled', js(image_name, kata_id)
    refute json['result']

    runner.teardown
  end

  # - - - - - - - - - - - - - - - - - - - - - -
  # TODO: need pulled? throwing an exception
  # - - - - - - - - - - - - - - - - - - - - - -

  test '406A3D',
  'pull succeeds with true/false' do
    set_runner_class('MockRunner')
    image_name = "#{cdf}/csharp_moq"
    kata_id = '406A3D5344'

    runner.mock_pull(image_name, kata_id, true)
    do_get 'pull', js(image_name, kata_id)
    assert json['result']

    runner.mock_pull(image_name, kata_id, false)
    do_get 'pull', js(image_name, kata_id)
    refute json['result']

    runner.teardown
  end

  # - - - - - - - - - - - - - - - - - - - - - -
  # TODO: need pulled? throwing an exception
  # - - - - - - - - - - - - - - - - - - - - - -

=begin
  # - - - - - - - - - - - - - - - - - - - - - -
  # from Fork on review page/dialog
  # - - - - - - - - - - - - - - - - - - - - - -

  test '406269',
  'kata pull_needed==false (from post start-point re-architecture)' do
    set_runner_class('MockRunner')
    set_storer_class('FakeStorer')
    runner.mock_pulled?("#{cdf}/csharp_nunit", true)
    runner.mock_new_kata("#{cdf}/csharp_nunit")
    create_kata('C#, NUnit')
    do_get 'pull_needed', id_js
    refute json['needed']
    runner.teardown
  end

  # - - - - - - - - - - - - - - - - - - - - - -

  test '406A97',
  'kata pull_needed==true (from post start-point re-architecture)' do
    set_runner_class('MockRunner')
    set_storer_class('FakeStorer')
    runner.mock_pulled?("#{cdf}/csharp_moq", false)
    runner.mock_new_kata("#{cdf}/csharp_moq")
    create_kata('C#, Moq')
    do_get 'pull_needed', id_js
    assert json['needed']
    runner.teardown
  end

  # - - - - - - - - - - - - - - - - - - - - - -

  test '406E66',
  'kata pull==true' do
    set_runner_class('MockRunner')
    set_storer_class('FakeStorer')
    runner.mock_pull("#{cdf}/csharp_moq", true)
    runner.mock_new_kata("#{cdf}/csharp_moq")
    create_kata('C#, Moq')
    do_get 'pull', id_js
    assert json['succeeded']
    runner.teardown
  end

  # - - - - - - - - - - - - - - - - - - - - - -

  test '406B07',
  'kata pull==false' do
    set_runner_class('MockRunner')
    set_storer_class('FakeStorer')
    runner.mock_pull("#{cdf}/csharp_moq", false)
    runner.mock_new_kata("#{cdf}/csharp_moq")
    create_kata('C#, Moq')
    do_get 'pull', id_js
    refute json['succeeded']
    runner.teardown
  end
=end

  private

  def do_get(route, params = {})
    controller = 'image_puller'
    get "#{controller}/#{route}", params
    assert_response :success
  end

  # - - - - - - - - - - - - - - - - - - - - - -

  def js(image_name, kata_id)
    {
      format: :js,
       image_name: image_name,
       id: kata_id
    }
  end

  # - - - - - - - - - - - - - - - - - - - - - -

  def cdf
    'cyberdojofoundation'
  end

end

