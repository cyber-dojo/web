require_relative 'lib_test_base'
require_relative '../../lib/disk_fake'
require_relative '../../lib/dir_fake'

class DiskDirFakeTest < LibTestBase

  test '447A8',
  'make returns true when it creates, afterwards false' do
    dir = disk['etc']
    refute dir.exists?
    assert dir.make
    assert dir.exists?
    refute dir.make
  end

  test '32486',
  'before make, exists? is false, after exists? is true' do
    dir = disk['etc']
    refute dir.exists?
    dir.make
    assert dir.exists?
  end

  test 'CC8D5',
  'write before make raises' do
    assert_raises { disk['a'].write('filename', '') }
  end

  test '76B79',
  'read before make raises' do
    assert_raises { disk['a'].read('filename') }
  end

  test '55FA7',
  'read reads what write wrote' do
    dir = disk['etc']
    dir.make
    filename = 'hiker.json'
    text = 'hello, world'
    dir.write(filename, text)
    assert_equal text, dir.read(filename)
  end

  test 'F4F72',
  'write overwrites previous write' do
    dir = disk['usr']
    dir.make
    filename = 'readme.json'
    dir.write(filename, 'hello')
    dir.write(filename, 'goodbye')
    assert_equal 'goodbye', dir.read(filename)
  end

  test '93082',
  'make creates all intermediate dirs' do
    dir = disk['a/b/c']
    refute disk['a'].exists?
    refute disk['a/b'].exists?
    refute disk['a/b/c'].exists?
    dir.make
    assert disk['a/b/c'].exists?
    assert disk['a/b'].exists?
    assert disk['a'].exists?
  end

  test '75862',
  'each_dir raises when exists is false' do
    assert_raises { disk['etc'].each_dir }
  end

  test '37D1B',
  'each_dir three levels deep' do
    dir = disk['etc/periodic/daily']
    dir.make
    all = disk['etc'].each_dir.collect { |name| name }
    assert_equal ['periodic'], all
    all = disk['etc/periodic'].each_dir.collect { |name| name }
    assert_equal ['daily'], all
    all = disk['etc/periodic/daily'].each_dir.collect { |name| name }
    assert_equal [], all
  end

  test 'A979F',
  'each_dir multiple dirs' do
    disk['etc/alpha'].make
    disk['etc/beta'].make
    all = disk['etc'].each_dir.collect { |name| name }
    assert_equal ['alpha','beta'].sort, all.sort
  end

  def disk
    @disk ||= DiskFake.new(self)
  end

end
