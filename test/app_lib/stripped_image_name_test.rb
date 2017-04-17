require_relative 'app_lib_test_base'

class StrippedImageNameTest < AppLibTestBase

  include StrippedImageName

  test '17FD8F6',
  'invalid image_names raise' do
    hex = '9'*32
    invalid_image_names = [
      '',              # nothing!
      '_',             # cannot start with separator
      'name_',         # cannot end with separator
      'ALPHA/name',    # no uppercase
      'alpha/name_',   # cannot end in separator
      'alpha/_name',   # cannot begin with separator
      'gcc:.',         # tag can't start with .
      'gcc:-',         # tag can't start with -
      'gcc:{}',        # bad tag
      "gcc:#{'x'*128}",# tag too long
      '-/gcc/assert:23',    # - is illegal hostname
      '-x/gcc/assert:23',   # -x is illegal hostname
      'x-/gcc/assert:23',   # x- is illegal hostname
      '/gcc/assert',        # remote-name can't start with /
      'gcc_assert@sha256:1234567890123456789012345678901',  # >=32 hex-digits
      "gcc_assert!sha256-2:#{hex}",  # need @ to start digest
      "gcc_assert@256:#{hex}",       # algorithm must start with letter
      "gcc_assert@sha256-2:#{hex}",  # alg-component must start with letter
      "gcc_assert@sha256#{hex}",     # need : to start hex-digits
    ]
    invalid_image_names.each do |invalid_image_name|
      error = assert_raises(ArgumentError) {
        stripped_image_name(invalid_image_name)
      }
      assert_equal 'image_name:invalid', error.message
    end
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  test '17FD8F7',
  'examples with no hostname' do
    assert_split('gcc_assert:_', '', '', 'gcc_assert', '_')
    assert_split('gcc_assert:2', '', '', 'gcc_assert', '2')
    assert_split('gcc_assert:a', '', '', 'gcc_assert', 'a')
    assert_split('gcc_assert:A', '', '', 'gcc_assert', 'A')
    assert_split('gcc_assert:1.2', '', '', 'gcc_assert', '1.2')
    assert_split('gcc_assert:1-2', '', '', 'gcc_assert', '1-2')
    assert_split("gcc_assert:#{'x'*127}", '', '', 'gcc_assert', 'x'*127)
    assert_split('gcc_assert', '', '', 'gcc_assert', '')
    assert_split('cdf/gcc_assert', '', '', 'cdf/gcc_assert', '')
    assert_split('cdf/gcc_assert:latest', '', '', 'cdf/gcc_assert', 'latest')
    assert_split('cdf/gcc__assert:x', '', '', 'cdf/gcc__assert', 'x')
    assert_split('cdf/gcc__sd.a--ssert:latest', '', '', 'cdf/gcc__sd.a--ssert', 'latest')

    hex = '12345678901234567890123456789012'
    assert_split("gcc_assert@sha256:#{hex}", '', '', 'gcc_assert', '')
    assert_split("gcc_assert@sha2-s1+s2.s3_s5:#{hex}", '', '', 'gcc_assert', '')

    assert_split("gcc_assert:tag@sha256:#{hex}", '', '', 'gcc_assert', 'tag')
    assert_split("gcc_assert:tag@sha2-s1+s2.s3_s5:#{hex}", '', '', 'gcc_assert', 'tag')

    assert_split("cdf/gcc_assert:tag@sha2-s1+s2.s3_s5:#{hex}", '', '', 'cdf/gcc_assert', 'tag')
    assert_split("cdf/gcc_assert:tag@sha2-s1+s2.s3_s5:#{hex}", '', '', 'cdf/gcc_assert', 'tag')
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  test '17FD8F8',
  'examples with hostname' do
    assert_split('localhost/cdf/gcc_assert', 'localhost', '', 'cdf/gcc_assert', '')
    assert_split('localhost:23/cdf/gcc_assert', 'localhost', '23', 'cdf/gcc_assert', '')
    assert_split('quay.io/cdf/gcc_assert', 'quay.io', '', 'cdf/gcc_assert', '')
    assert_split('quay.io:80/cdf/gcc_assert', 'quay.io', '80', 'cdf/gcc_assert', '')

    assert_split('localhost/cdf/gcc_assert:latest', 'localhost', '', 'cdf/gcc_assert', 'latest')
    assert_split('localhost:23/cdf/gcc_assert:latest', 'localhost', '23', 'cdf/gcc_assert', 'latest')
    assert_split('quay.io/cdf/gcc_assert:latest', 'quay.io', '', 'cdf/gcc_assert', 'latest')
    assert_split('quay.io:80/cdf/gcc_assert:latest', 'quay.io', '80', 'cdf/gcc_assert', 'latest')

    assert_split('localhost/cdf/gcc__assert:x', 'localhost', '', 'cdf/gcc__assert', 'x')
    assert_split('localhost:23/cdf/gcc__assert:x', 'localhost', '23', 'cdf/gcc__assert', 'x')
    assert_split('quay.io/cdf/gcc__assert:x', 'quay.io', '', 'cdf/gcc__assert', 'x')
    assert_split('quay.io:80/cdf/gcc__assert:x', 'quay.io', '80', 'cdf/gcc__assert', 'x')

    assert_split('localhost/cdf/gcc__sd.a--ssert:latest', 'localhost', '', 'cdf/gcc__sd.a--ssert', 'latest')
    assert_split('localhost:23/cdf/gcc__sd.a--ssert:latest', 'localhost', '23', 'cdf/gcc__sd.a--ssert', 'latest')
    assert_split('quay.io/cdf/gcc__sd.a--ssert:latest', 'quay.io', '', 'cdf/gcc__sd.a--ssert', 'latest')
    assert_split('quay.io:80/cdf/gcc__sd.a--ssert:latest', 'quay.io', '80', 'cdf/gcc__sd.a--ssert', 'latest')

    assert_split('a-b-c:80/cdf/gcc__sd.a--ssert:latest', 'a-b-c', '80', 'cdf/gcc__sd.a--ssert', 'latest')
    assert_split('a.b.c:80/cdf/gcc__sd.a--ssert:latest', 'a.b.c', '80', 'cdf/gcc__sd.a--ssert', 'latest')
    assert_split('A.B.C:80/cdf/gcc__sd.a--ssert:latest', 'A.B.C', '80', 'cdf/gcc__sd.a--ssert', 'latest')

    hex = '1234567890123456789012345678901234'
    assert_split("localhost/gcc_assert@sha2-s1+s2.s3_s5:#{hex}", 'localhost', '', 'gcc_assert', '')
    assert_split("localhost:80/gcc_assert@sha2-s1+s2.s3_s5:#{hex}", 'localhost', '80', 'gcc_assert', '')
    assert_split("localhost:80/gcc_assert:tag@sha2-s1+s2.s3_s5:#{hex}", 'localhost', '80', 'gcc_assert', 'tag')
    assert_split("localhost:80/cdf/gcc_assert:tag@sha2-s1+s2.s3_s5:#{hex}", 'localhost', '80', 'cdf/gcc_assert', 'tag')
    assert_split("quay.io/gcc_assert@sha2-s1+s2.s3_s5:#{hex}", 'quay.io', '', 'gcc_assert', '')
    assert_split("quay.io:80/gcc_assert@sha2-s1+s2.s3_s5:#{hex}", 'quay.io', '80', 'gcc_assert', '')
    assert_split("quay.io:80/gcc_assert:latest@sha2-s1+s2.s3_s5:#{hex}", 'quay.io', '80', 'gcc_assert', 'latest')
    assert_split("quay.io:80/cdf/gcc_assert:latest@sha2-s1+s2.s3_s5:#{hex}", 'quay.io', '80', 'cdf/gcc_assert', 'latest')
    assert_split("q.uay.io:80/cdf/gcc_assert:latest@sha2-s1+s2.s3_s5:#{hex}", 'q.uay.io', '80', 'cdf/gcc_assert', 'latest')
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  def assert_split(image_name, hostname, port, name, tag)
    hostname += ':' unless port == ''
    hostname += port
    expected = {
      hostname:hostname,
      name:name,
      tag:tag
    }
    assert_equal expected, split_image_name(image_name)
    assert_equal name, stripped_image_name(image_name)
  end

end
