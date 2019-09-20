require_relative 'lib_test_base'

class ShaTest < LibTestBase

  def self.hex_prefix
    'Fv3'
  end

  # - - - - - - - - - - - - - - - - -

  test '191', %w(
  sha of git commit for image is set as env-var
  ) do
    sha = ENV['SHA']
    assert_equal 40, sha.size
    sha.each_char do |ch|
      assert "0123456789abcdef".include?(ch)
    end
  end

end
