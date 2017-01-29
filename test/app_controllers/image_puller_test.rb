require_relative './app_controller_test_base'

class MockRunner

  @@pulled = []
  @@pull = []
  @@new_kata = []

  def initialize(_parent)
  end

  def teardown
    error "@@pulled != []:#{@@pulled}" unless @@pulled == []
    error "@@pull != []:#{@@pull}" unless @@pull == []
    error "@@new_kata != []:#{@@new_kata}" unless @@new_kata == []
  end

  def mock_pulled?(image_name, result)
    @@pulled << [image_name, result]
  end

  def pulled?(image_name)
    error "no mock for pulled?(#{image_name})" if @@pulled == []
    mock = @@pulled.shift
    error "expecting #{mock[0]}, actual:#{image_name}" unless mock[0] == image_name
    mock[1]
  end

  # - - - - - - - - - - - - - - - - - - - -

  def mock_pull(image_name, result)
    @@pull << [image_name, result]
  end

  def pull(image_name)
    error "no mock for pull(#{image_name})" if @@pull == []
    mock = @@pull.shift
    error "expected #{mock[0]}:actual #{image_name}" unless mock[0] == image_name
    mock[1]
  end

  # - - - - - - - - - - - - - - - - - - - -

  def mock_new_kata(image_name)
    @@new_kata << image_name
  end
  def new_kata(image_name, _kata_id)
    error "no mock for new_kata(#{image_name},kata_id)" if @@new_kata == []
    mock = @@new_kata.shift
    error "expected #{mock}:actual #{image_name}" unless mock == image_name
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
  'language pull_needed==true' do
    set_runner_class('MockRunner')
    runner.mock_pulled?("#{cdf}/csharp_moq", false)
    do_get 'pull_needed', major_minor_js('language', 'C#', 'Moq')
    assert json['needed']
    runner.teardown
  end

  # - - - - - - - - - - - - - - - - - - - - - -

  test '406A3D',
  'language pull_needed==false' do
    set_runner_class('MockRunner')
    runner.mock_pulled?("#{cdf}/csharp_nunit", true)
    do_get 'pull_needed', major_minor_js('language', 'C#', 'NUnit')
    refute json['needed']
    runner.teardown
  end

  # - - - - - - - - - - - - - - - - - - - - - -

  test '406080',
  'language pull=true' do
    set_runner_class('MockRunner')
    runner.mock_pull("#{cdf}/csharp_nunit", true)
    do_get 'pull', major_minor_js('language', 'C#', 'NUnit')
    assert json['succeeded']
    runner.teardown
  end

  # - - - - - - - - - - - - - - - - - - - - - -

  test '4063FD',
  'language pull==false' do
    set_runner_class('MockRunner')
    runner.mock_pull("#{cdf}/csharp_nunit", false)
    do_get 'pull', major_minor_js('language', 'C#', 'NUnit')
    refute json['succeeded']
    runner.teardown
  end

  # - - - - - - - - - - - - - - - - - - - - - -
  # from Custom setup page
  # - - - - - - - - - - - - - - - - - - - - - -

  test '406C10',
  'custom pull_needed==false' do
    set_runner_class('MockRunner')
    runner.mock_pulled?("#{cdf}/python_unittest", false)
    do_get 'pull_needed', major_minor_js('custom', 'Tennis refactoring', 'Python unitttest')
    assert json['needed']
    runner.teardown
  end

  # - - - - - - - - - - - - - - - - - - - - - -

  test '406E9A',
  'custom pull_needed==true' do
    set_runner_class('MockRunner')
    runner.mock_pulled?("#{cdf}/csharp_nunit", true)
    do_get 'pull_needed', major_minor_js('custom', 'Tennis refactoring', 'C# NUnit')
    refute json['needed']
    runner.teardown
  end

  # - - - - - - - - - - - - - - - - - - - - - -

  test '4064A0',
  'custom pull==true' do
    set_runner_class('MockRunner')
    runner.mock_pull("#{cdf}/python_unittest", true)
    do_get 'pull', major_minor_js('custom', 'Tennis refactoring', 'Python unitttest')
    assert json['succeeded']
    runner.teardown
  end

  # - - - - - - - - - - - - - - - - - - - - - -

  test '4065E7',
  'custom pull==false' do
    set_runner_class('MockRunner')
    runner.mock_pull("#{cdf}/python_unittest", false)
    do_get 'pull', major_minor_js('custom', 'Tennis refactoring', 'Python unitttest')
    refute json['succeeded']
    runner.teardown
  end

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

  private

  def do_get(route, params = {})
    controller = 'image_puller'
    get "#{controller}/#{route}", params
    assert_response :success
  end

  # - - - - - - - - - - - - - - - - - - - - - -

  def major_minor_js(type, major, minor)
    {
      format: :js,
        type: type,
       major: major,
       minor: minor
    }
  end

  # - - - - - - - - - - - - - - - - - - - - - -

  def id_js
    {
        type: :kata,
      format: :js,
          id: @id
    }
  end

  # - - - - - - - - - - - - - - - - - - - - - -

  def cdf
    'cyberdojofoundation'
  end

end
