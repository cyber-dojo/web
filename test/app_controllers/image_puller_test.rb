require_relative './app_controller_test_base'

class ImagePullerTest < AppControllerTestBase

  # - - - - - - - - - - - - - - - - - - - - - -
  # TODO: need pulled? throwing an exception?
  # TODO: need pull throwing an exception?
  # - - - - - - - - - - - - - - - - - - - - - -

  test '406596',
  'pulled? succeeds with true/false' do
    set_puller_class('PullerMock')
    image_name = "#{cdf}/csharp_moq"

    puller.mock_pulled?(image_name, true)
    do_get 'pulled', js(image_name)
    assert json['result']

    puller.mock_pulled?(image_name, false)
    do_get 'pulled', js(image_name)
    refute json['result']

    puller.teardown
  end

  test '406A3D',
  'pull succeeds with true/false' do
    set_puller_class('PullerMock')
    image_name = "#{cdf}/csharp_moq"

    puller.mock_pull(image_name, true)
    do_get 'pull', js(image_name)
    assert json['result']

    puller.mock_pull(image_name, false)
    do_get 'pull', js(image_name)
    refute json['result']

    puller.teardown
  end

  private

  def do_get(route, params = {})
    controller = 'image_puller'
    get "#{controller}/#{route}", params
    assert_response :success
  end

  # - - - - - - - - - - - - - - - - - - - - - -

  def js(image_name)
    {
      format: :js,
       image_name: image_name
    }
  end

  # - - - - - - - - - - - - - - - - - - - - - -

  def cdf
    'cyberdojofoundation'
  end

end

# = = = = = = = = = = = = = = = = = = = = = = =

=begin
class MockRunner

  @@new_kata = []

  def initialize(_parent)
  end

  def teardown
    error "@@new_kata != []:#{@@new_kata}" unless @@new_kata == []
  end

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
=end
