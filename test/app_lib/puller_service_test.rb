require_relative 'app_lib_test_base'

class PullerServiceTest < AppLibTestBase

  # These will fail if there is no network connectivity.

  test 'D4F808',
  'smoke test puller' do
    refute puller.pulled? 'cyberdojo/non_existant', kata_id
    image_name = 'cyberdojofoundation/gcc_assert'
    assert puller.pull image_name, kata_id
    assert puller.pulled? image_name, kata_id
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - -

  test 'D4FCD3',
  'smoke test pulled?() raises for invalid image_name' do
    invalid_image_names.each do |invalid_image_name|
      assert_raises_invalid_image('pulled?') {
        puller.pulled?(invalid_image_name, kata_id)
      }
    end
  end

  test 'D4FCD4',
  'smoke test pull() raises for invalid image_name' do
    invalid_image_names.each do |invalid_image_name|
      assert_raises_invalid_image('pull') {
        puller.pull(invalid_image_name, kata_id)
      }
    end
  end

  private

  def assert_raises_invalid_image(method)
    error = assert_raises { yield }
    expected = "PullerService:#{method}:image_name:invalid"
    assert error.message.start_with?(expected), error.message
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - -

  def invalid_image_names
    [
      '',             # nothing!
      '_',            # cannot start with separator
      'name_',        # cannot end with separator
      'ALPHA/name',   # no uppercase
      'alpha/name_',  # cannot end in separator
      'alpha/_name',  # cannot begin with separator
    ]
  end

  def kata_id
    '263CEF6990'
  end

end
