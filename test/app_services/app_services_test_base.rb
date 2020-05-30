require_relative '../all'

class AppServicesTestBase < TestBase

  def creation_time
    [ 2016,12,5, 17,44,23 ]
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - -

  def tag0
    {
      'event'  => 'created',
      'time'   => creation_time,
      'index'  => 0
    }
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - -

  def assert_sha(sha)
    assert_equal(40, sha.size)
    sha.chars.all? { |ch| assert is_hex?(ch), ch }
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - -

  def is_hex?(ch)
    '0123456789abcdef'.include?(ch)
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - -

  def assert_starts_with(visible_files, filename, content)
    actual = visible_files[filename]['content']
    diagnostic = [
      "filename:#{filename}",
      "expected:#{content}:",
      "--actual:#{actual.split[0]}:"
    ].join("\n")
    assert actual.start_with?(content), diagnostic
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - -

  def assert_includes(visible_files, filename, content)
    actual = visible_files[filename]['content']
    diagnostic = [
      "filename:#{filename}",
      "!include:#{content}:"
    ].join("\n")
    assert actual.include?(content), diagnostic
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - -

  def set_http(klass)
    @http = klass
  end

end
