require_relative 'lib_test_base'

class DiskDirHostTest < LibTestBase

  test '437EB1',
  'disk[...].path always ends in /' do
    dir.make
    assert_equal 'ABC/', disk['ABC'].path
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  test '4375F3',
  'disk[path].make returns true when it makes the directory',
  'false when it does not' do
    refute dir.exists?
    assert dir.make
    assert dir.exists?
    refute dir.make
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  test '437CE8',
  'disk[path].exists?(filename) false when file does not exist, true when it does' do
    dir.make
    refute dir.exists?(filename = 'hello.txt')
    dir.write(filename, 'content')
    assert dir.exists?(filename)
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  test '437EAB',
  'disk[path].read() reads back what was written' do
    dir.make
    dir.write('filename', expected = 'content')
    assert_equal expected, dir.read('filename')
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  test '437A9F',
  'write(filename, content) raises RuntimeError when content is not a string' do
    dir.make
    assert_raises(RuntimeError) { dir.write('any.txt', Object.new) }
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  test '43729F',
  'write(filename, content) succeeds when content is a string' do
    dir.make
    content = 'hello world'
    check_save_file('manifest.rb', content, content)
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  test '437C6D',
  'write_json(filename, content) raises RuntimeError when filename does not end in .json' do
    dir.make
    assert_raises(RuntimeError) { dir.write_json('file.txt', 'any') }
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  test '437891',
  'read_json(filename) raises RuntimeError when filename is empty' do
    dir.make
    dir.write(filename='601891.json', empty='')
    expected_message = "DirHost(#{path}/).read_json(#{filename}) - empty file"
    assert_raises_with_message(RuntimeError, expected_message) { dir.read_json(filename) }
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  test '4376EE',
  'read_json(filename) raises RuntimeError when filename does not end in .json' do
    dir.make
    assert_raises(RuntimeError) { dir.read_json('file.txt') }
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  test '4372F4',
  'write_json(filename, object) saves JSON.unparse(object) in filename' do
    dir.make
    dir.write_json(filename = 'object.json', { :a => 1, :b => 2 })
    json = dir.read(filename)
    object = JSON.parse(json)
    assert_equal 1, object['a']
    assert_equal 2, object['b']
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  test '437336',
  'write_json_once succeeds once then its a no-op' do
    dir.make
    filename = 'once.json'
    refute dir.exists? filename
    dir.write_json_once(filename) { {:a=>1, :b=>2 } }
    assert dir.exists? filename
    object = dir.read_json(filename)
    assert_equal 1, object['a']
    assert_equal 2, object['b']
    dir.write_json_once(filename) { {:a=>3, :b=>4 } }
    object = dir.read_json(filename)
    assert_equal 1, object['a']
    assert_equal 2, object['b']
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  test '43739D',
  'object = read_json(filename) after write_json(filename, object) round-strips ok' do
    dir.make
    dir.write_json(filename = 'object.json', { :a => 1, :b => 2 })
    object = dir.read_json(filename)
    assert_equal 1, object['a']
    assert_equal 2, object['b']
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  test '437A3E',
  'save file for non executable file' do
    dir.make
    check_save_file('file.a', 'content', 'content')
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  test '437931',
  'save file for executable file' do
    dir.make
    check_save_file('file.sh', 'ls', 'ls')
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  test '437E30',
  'save filename ending in makefile is not auto-tabbed' do
    dir.make
    content = '    abc'
    expected_content = content # leading spaces not converted to tabs
    ends_in_makefile = 'smakefile'
    check_save_file(ends_in_makefile, content, expected_content)
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  test '437ACA',
  'disk.dir?(.) is true' do
    dir.make
    assert disk.dir?(path + '/' + '.')
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  test '437A3F',
  'disk.dir?(..) is true' do
    dir.make
    assert disk.dir?(path + '/' + '..')
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  test '43740A',
  'disk.dir?(not-a-dir) is false' do
    dir.make
    refute disk.dir?('blah-blah')
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  test '437E82',
  'disk.dir?(a-dir) is true' do
    dir.make
    assert disk.dir?(path)
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  test '4373B9',
  'dir.each_dir' do
    dir.make
    cwd = `pwd`.strip + '/../'
    dirs = disk[cwd].each_dir.entries
    %w( app_helpers app_lib ).each { |dir_name| assert dirs.include?(dir_name), dir_name }
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  test '437637',
  'dir.each_rdir yields dirs of given filename at any dir depth' do
    dir.make
    disk[path].write('a.txt', 'content')
    disk[path + '/' + 'alpha'].make
    disk[path + '/' + 'alpha'].write('a.txt', 'a')
    disk[path + '/' + 'alpha' + '/' + 'beta'].make
    disk[path + '/' + 'alpha' + '/' + 'beta'].write('a.txt', 'a')
    dir_names = []
    disk[path].each_rdir('a.txt') { |dir_name| dir_names << dir_name }
    expected = [
      path,
      path + '/' + 'alpha',
      path + '/' + 'alpha' + '/' + 'beta',
    ]
    assert_equal expected.sort, dir_names.sort
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  test '437408',
  'disk[path].each_dir does not give filenames' do
    dir.make
    disk[path].write('beta.txt', 'content')
    disk[path + '/' + 'alpha'].make
    disk[path + '/' + 'alpha'].write('a.txt', 'a')
    assert_equal ['alpha'], disk[path].each_dir.entries
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  test '43711C',
  'disk[path].each_dir.select' do
    dir.make
    disk[path + '/' + 'alpha'].make
    disk[path + '/' + 'beta' ].make
    disk[path + '/' + 'alpha'].write('a.txt', 'a')
    disk[path + '/' + 'beta' ].write('b.txt', 'b')
    matches = disk[path].each_dir.select { |dir| dir.start_with?('a') }
    assert_equal ['alpha'], matches.sort
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  test '43754E',
  'disk[path].each_file' do
    dir.make
    disk[path + '/' + 'a'].make
    disk[path + '/' + 'a'].write('c.txt', 'content')
    disk[path + '/' + 'a'].write('d.txt', 'content')
    assert_equal ['c.txt','d.txt'], disk[path + '/' + 'a'].each_file.entries.sort
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  test '437EA2',
  'disk[path].each_file does not give dirs' do
    dir.make
    disk[path].make
    disk[path].write('beta.txt', 'content')
    disk[path + '/' + 'alpha'].make
    disk[path + '/' + 'alpha'].write('a.txt', 'a')
    assert_equal ['beta.txt'], disk[path].each_file.entries
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  test '4379F8',
  'disk[path].each_file.select' do
    dir.make
    disk[path + '/' + 'a'].make
    disk[path + '/' + 'a'].write('b.cpp', 'content')
    disk[path + '/' + 'a'].write('c.txt', 'content')
    disk[path + '/' + 'a'].write('d.txt', 'content')
    matches = disk[path + '/' + 'a'].each_file.select do |filename|
      filename.end_with?('.txt')
    end
    assert_equal ['c.txt','d.txt'], matches.sort
  end

  private

  def check_save_file(filename, content, expected_content)
    dir.write(filename, content)
    pathed_filename = path + '/' + filename
    assert File.exist?(pathed_filename),
          "File.exist?(#{pathed_filename})"
    assert_equal expected_content, IO.read(pathed_filename)
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  def assert_raises_with_message(exception, msg, &block)
    begin
      raised = false
      block.call
    rescue exception => e
      assert_equal msg, e.message
      raised = true
    end
    assert raised, "Expected to raise #{exception} w/ message #{msg}"
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  def dir
    disk[path]
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  def path
    tmp_root + '/' + 'host_disk_dir_tests' + '/' + hex_test_kata_id
  end

end
