require_relative 'app_lib_test_base'

class ImageNameSplitterTest < AppLibTestBase

  include ImageNameSplitter

  test '17FD8F6',
  'invalid image_names raise' do
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
      'x-/gcc/assert:23'    # x- is illegal hostname
    ]
    invalid_image_names.each do |invalid_image_name|
      error = assert_raises(ArgumentError) {
        split_image_name(invalid_image_name)
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
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  def assert_split(image_name, hostname, port, name, tag)
    o = split_image_name(image_name)
    assert_equal({
      :hostname => hostname,
      :port => port,
      :name => name,
      :tag => tag
    }, o)
  end

end
