require_relative './app_controller_test_base'

class ImagePullerTest < AppControllerTestBase

  test '406D78',
  'pulled? raises when image_name is invalid' do
    image_name = '_cantStartWithSeparator'
    do_get 'pulled', js(image_name)
    refute json['result']
  end

  # - - - - - - - - - - - - - - - - - - - - - -

  test '406167',
  'pull raises when image_name is invalid' do
    image_name = '_cantStartWithSeparator'
    do_get 'pull', js(image_name)
    refute json['result']
  end

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

  # - - - - - - - - - - - - - - - - - - - - - -

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
