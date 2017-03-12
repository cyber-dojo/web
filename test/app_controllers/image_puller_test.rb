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

=begin
  test '406596',
  'pulled? succeeds with true/false' do
    image_name = "#{cdf}/gcc_assert"
    do_get 'pull', js(image_name)
    assert json['result']
    do_get 'pulled', js(image_name)
    assert json['result']
  end
=end

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
       image_name: image_name,
       id: '9CBA773309'
    }
  end

  # - - - - - - - - - - - - - - - - - - - - - -

  def cdf
    'cyberdojofoundation'
  end

end
