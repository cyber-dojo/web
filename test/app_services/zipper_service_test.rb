require_relative 'app_services_test_base'

class ZipperServiceTest < AppServicesTestBase

  def self.hex_prefix
    'D1279C'
  end

  def hex_setup
    set_differ_class('NotUsed')
    set_starter_class('NotUsed')
    set_storer_class('StorerFake')
    set_runner_class('NotUsed')
  end

  # - - - - - - - - - - - - - - - - - - - - -

  test 'C16',
  'smoke test zipper.sha' do
    sha = zipper.sha
    assert_equal 40, sha.size
    sha.each_char do |ch|
      assert "0123456789abcdef".include?(ch)
    end
  end

  # - - - - - - - - - - - - - - - - - - - - -

  test 'EBF',
  'smoke test zipper.zip' do
    error = assert_raises { zipper.zip(kata_id='') }
    assert error.message.start_with?('ZipperService:'), error.message
    assert error.message.end_with?('kata_id:malformed'), error.message
  end

  # - - - - - - - - - - - - - - - - - - - - -

  test '959',
  'smoke test zipper.zip_tag' do
    error = assert_raises { zipper.zip_tag(kata_id='', 'lion', 0) }
    assert error.message.start_with?('ZipperService:'), error.message
    assert error.message.end_with?('kata_id:malformed'), error.message
  end

end
