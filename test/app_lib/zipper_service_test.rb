require_relative 'app_lib_test_base'

class ZipperServiceTest < AppLibTestBase

  test 'D66EBF',
  'smoke test zipper.zip' do
    error = assert_raises { zipper.zip(kata_id='') }
    assert error.message.end_with?('invalid kata_id'), error.message
  end

  test 'D66959',
  'smoke test zipper.zip_tag' do
    error = assert_raises { zipper.zip_tag(kata_id='', 'lion', 0) }
    assert error.message.end_with?('invalid kata_id'), error.message
  end

end
