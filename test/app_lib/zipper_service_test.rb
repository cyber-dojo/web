require_relative 'app_lib_test_base'

class ZipperServiceTest < AppLibTestBase

  test 'D66EBF',
  'smoke test zipper' do
    error = assert_raises { zipper.zip(kata_id='') }
    assert error.message.end_with?('invalid kata_id'), error.message
  end

end
