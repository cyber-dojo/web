require_relative './app_controller_test_base'

class ImagePullerTest < AppControllerTestBase

  def self.hex_prefix
    '4068F5'
  end

  def hex_setup
    set_runner_class('RunnerService')
  end

  # - - - - - - - - - - - - - - - - - - - - - -

  test '736', 'pulled?' do
    refute_image_pulled(invalid_image_name, valid_kata_id(true))
    refute_image_pulled(valid_non_existent_image_name, valid_kata_id(false))
    refute_image_pulled(valid_existing_image_name, valid_kata_id(false))

    kata = make_language_kata
    assert kata.runner_choice == 'stateless' # no need to do runner.kata_old
    assert_image_pull(valid_existing_image_name, kata.id)
    assert_image_pulled(valid_existing_image_name, kata.id)
  end

  # - - - - - - - - - - - - - - - - - - - - - -

  test '167', 'pull' do
    refute_image_pull(invalid_image_name, valid_kata_id(true))
    refute_image_pull(valid_non_existent_image_name, valid_kata_id(false))
    refute_image_pull(valid_existing_image_name, valid_kata_id(false))
    kata = make_language_kata
    assert kata.runner_choice == 'stateless' # no need to do runner.kata_old
    assert_image_pull(valid_existing_image_name, kata.id)
  end

  private

  def assert_image_pulled(image_name, kata_id)
    do_get 'image_pulled', image_name, kata_id
    assert_equal true, json['result']
  end

  def refute_image_pulled(image_name, kata_id)
    do_get 'image_pulled', image_name, kata_id
    assert_equal false, json['result']
  end

  # - - - - - - - - - - - - - - - - - - - - - -

  def assert_image_pull(image_name, kata_id)
    do_get 'image_pull', image_name, kata_id
    assert_equal true, json['result']
  end

  def refute_image_pull(image_name, kata_id)
    do_get 'image_pull', image_name, kata_id
    assert_equal false, json['result']
  end

  # - - - - - - - - - - - - - - - - - - - - - -

  def do_get(route, image_name, kata_id)
    controller = 'image_puller'
    get "/#{controller}/#{route}", params: {
           format: :js,
       image_name: image_name,
               id: kata_id
    }
    assert_response :success
  end

  # - - - - - - - - - - - - - - - - - - - - - -

  def valid_kata_id(tf)
    tf ? 'B7A0D65F97' : 'salmon'
  end

  def invalid_image_name
    '_cantStartWithSeparator'
  end

  def valid_non_existent_image_name
    'does_not_exist'
  end

  def valid_existing_image_name
    'cyberdojofoundation/gcc_assert'
  end

end
