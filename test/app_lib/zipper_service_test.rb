require_relative 'app_lib_test_base'

class ZipperServiceTest < AppLibTestBase

  test 'D66EBF',
  'smoke test zipper' do
    error = assert_raises { zipper.zip(kata_id='') }
    expected = 'ZipperService:zip:Zipper:invalid kata_id'
    assert error.message.start_with?(expected), error.message
  end

end
