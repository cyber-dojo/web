require_relative './lib_test_base'
require_relative './../../lib/fake_disk'
require_relative './../../lib/fake_dir'

class FakeDiskDirTest < LibTestBase

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

  test 'CC8D5E',
  'write_json before make raises' do
    assert_raises { disk['a'].write_json('filename', {}) }
  end

  test '76B79',
  'read_json before make raises' do
    assert_raises { disk['a'].read_json('filename') }
  end

  test '55FA7',
  'read_json reads what write_json wrote' do
    dir = disk['etc']
    dir.make
    filename = 'hiker.json'
    json = { 'a' => 24 }
    dir.write_json(filename, json)
    assert_equal json, dir.read_json(filename)
  end

  test 'F4F72',
  'write_json overwrites previous write_json' do
    dir = disk['usr']
    dir.make
    filename = 'readme.json'
    dir.write_json(filename, { 'a' => 42 })
    dir.write_json(filename, json = { 'b' => 24 })
    assert_equal json, dir.read_json(filename)
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
    @disk ||= FakeDisk.new(self)
  end

end
