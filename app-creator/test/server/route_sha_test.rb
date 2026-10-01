require_relative 'creator_test_base'

class RouteShaTest < CreatorTestBase

  # - - - - - - - - - - - - - - - - -

  qtest de3p23: %w[
    |GET /sha
    |has status 200
    |returns the 40-char git commit sha used to create the image
    |and nothing else
  ] do
    assert_get_200_json(key = 'sha') do |jr|
      assert_equal [key], jr.keys, last_response.body
      sha = jr[key]
      assert git_sha?(sha), sha
    end
  end

  private

  def git_sha?(str)
    str.instance_of?(String) &&
      str.size == 40 &&
      str.chars.all? { |ch| lo_hex?(ch) }
  end

  def lo_hex?(char)
    '0123456789abcdef'.include?(char)
  end
end
