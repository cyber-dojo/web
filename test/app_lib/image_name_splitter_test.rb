require_relative 'app_lib_test_base'

class ImageNameSplitterTest < AppLibTestBase

  include ImageNameSplitter

  def assert_split(image_name, hostname, name, tag)
    o = split_image_name(image_name)
    assert_equal({
      :hostname => hostname,
      :name => name,
      :tag => tag
    }, o)
  end

  test '17FD8F7',
  'examples with no hostname' do
    assert_split('cdf/gcc_assert', '', 'cdf/gcc_assert', '')
    assert_split('cdf/gcc_assert:latest', '', 'cdf/gcc_assert', 'latest')
    assert_split('cdf/gcc__assert:x', '', 'cdf/gcc__assert', 'x')
    assert_split('cdf/gcc__sd.a--ssert:latest', '', 'cdf/gcc__sd.a--ssert', 'latest')
  end

  test '17FD8F8',
  'examples with hostname' do
    assert_split('localhost/cdf/gcc_assert', 'localhost', 'cdf/gcc_assert', '')
    assert_split('localhost:23/cdf/gcc_assert', 'localhost:23', 'cdf/gcc_assert', '')
    assert_split('quay.io/cdf/gcc_assert', 'quay.io', 'cdf/gcc_assert', '')
    assert_split('quay.io:80/cdf/gcc_assert', 'quay.io:80', 'cdf/gcc_assert', '')

    assert_split('localhost/cdf/gcc_assert:latest', 'localhost', 'cdf/gcc_assert', 'latest')
    assert_split('localhost:23/cdf/gcc_assert:latest', 'localhost:23', 'cdf/gcc_assert', 'latest')
    assert_split('quay.io/cdf/gcc_assert:latest', 'quay.io', 'cdf/gcc_assert', 'latest')
    assert_split('quay.io:80/cdf/gcc_assert:latest', 'quay.io:80', 'cdf/gcc_assert', 'latest')

    assert_split('localhost/cdf/gcc__assert:x', 'localhost', 'cdf/gcc__assert', 'x')
    assert_split('localhost:23/cdf/gcc__assert:x', 'localhost:23', 'cdf/gcc__assert', 'x')
    assert_split('quay.io/cdf/gcc__assert:x', 'quay.io', 'cdf/gcc__assert', 'x')
    assert_split('quay.io:80/cdf/gcc__assert:x', 'quay.io:80', 'cdf/gcc__assert', 'x')

    assert_split('localhost/cdf/gcc__sd.a--ssert:latest', 'localhost', 'cdf/gcc__sd.a--ssert', 'latest')
    assert_split('localhost:23/cdf/gcc__sd.a--ssert:latest', 'localhost:23', 'cdf/gcc__sd.a--ssert', 'latest')
    assert_split('quay.io/cdf/gcc__sd.a--ssert:latest', 'quay.io', 'cdf/gcc__sd.a--ssert', 'latest')
    assert_split('quay.io:80/cdf/gcc__sd.a--ssert:latest', 'quay.io:80', 'cdf/gcc__sd.a--ssert', 'latest')
  end


end
