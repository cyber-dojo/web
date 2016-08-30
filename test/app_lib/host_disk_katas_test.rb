#!/bin/bash ../test_wrapper.sh

require_relative './app_lib_test_base'

class HostDiskKatasTest < AppLibTestBase

  def setup
    super
    set_runner_class('StubRunner')
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  # katas.create_kata()
  #- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  test 'B9916D',
  'after create_kata() manifest file holds kata properties' do
    kata = make_kata
    manifest = katas.kata_manifest(kata.id)
    assert_equal kata.id, manifest['id']
    refute_nil manifest['image_name']
    refute_nil manifest['language']
    refute_nil manifest['tab_size']
    refute_nil manifest['id']
    refute_nil manifest['created']
    refute_nil manifest['visible_files']
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  # katas[id]
  #- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  test 'DFB053',
  'katas[id] is kata with existing id' do
    kata = make_kata
    k = katas[kata.id.to_s]
    refute_nil k
    assert_equal k.id.to_s, kata.id.to_s
  end

  test 'D0A1F6',
  'katas[id] for id that is not a string is nil' do
    not_string = Object.new
    assert_nil katas[not_string]
    nine = unique_id[0..-2]
    assert_equal 9, nine.length
    assert_nil katas[nine]
  end

  test 'A0DF10',
  'katas[id] for 10 digit id with non hex-chars is nil' do
    has_a_g = '123456789G'
    assert_equal 10, has_a_g.length
    assert_nil katas[has_a_g]
  end

  test '64F53B',
  'katas[id] for non-existing id is nil' do
    id = '123456789A'
    assert_equal 10, id.length
    assert_nil katas[id]
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  # katas.each()
  #- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  test '603735',
  'each() yields empty array when there are no katas' do
    assert_equal [], all_ids
  end

  test '5A2932',
  'each() yields one kata-id' do
    kata = make_kata
    assert_equal [kata.id.to_s], all_ids
  end

  test '24894F',
  'each() yields two unrelated kata-ids' do
    kata1 = make_kata
    kata2 = make_kata
    assert_equal all_ids([kata1, kata2]).sort, all_ids.sort
  end

  test '29DFD1',
  'each() yields several kata-ids with common first two characters' do
    id = 'ABCDE1234'
    assert_equal 10-1, id.length
    kata1 = make_kata({ id:id + '1' })
    kata2 = make_kata({ id:id + '2' })
    kata3 = make_kata({ id:id + '3' })
    assert_equal all_ids([kata1, kata2, kata3]).sort, all_ids.sort
  end

  test 'F71C21',
  'is Enumerable: so .each not needed if doing map' do
    kata1 = make_kata
    kata2 = make_kata
    assert_equal all_ids([kata1, kata2]).sort, all_ids.sort
  end

  def all_ids(k = katas)
    k.map { |kata| kata.id }
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  # katas.completed(id)
  #- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  test 'B652EC',
  'completed(id=nil) is empty string' do
    assert_equal '', katas.completed(nil)
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  test 'D391CE',
  'completed(id="") is empty string' do
    assert_equal '', katas.completed('')
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  test '42EA20',
  'completed(id) does not complete when id is less than 6 chars in length',
  'because trying to complete from a short id will waste time going through',
  'lots of candidates (on disk) with the likely outcome of no unique result' do
    id = unique_id[0..4]
    assert_equal 5, id.length
    assert_equal id, katas.completed(id)
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  test '071A62',
  'completed(id) unchanged when no matches' do
    id = unique_id
    (0..7).each { |size| assert_equal id[0..size], katas.completed(id[0..size]) }
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  test '23B4F1',
  'completed(id) does not complete when 6+ chars and more than one match' do
    uncompleted_id = 'ABCDE1'
    make_kata({ id:uncompleted_id + '234' + '5' })
    make_kata({ id:uncompleted_id + '234' + '6' })
    assert_equal uncompleted_id, katas.completed(uncompleted_id)
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  test '0934BF',
  'completed(id) completes when 6+ chars and 1 match' do
    completed_id = 'A1B2C3D4E5'
    make_kata({ id:completed_id })
    uncompleted_id = completed_id.downcase[0..5]
    assert_equal completed_id, katas.completed(uncompleted_id)
  end

  #- - - - - - - - - - - - - - - -
  # start_avatar
  #- - - - - - - - - - - - - - - -

  test '81C023',
  'unstarted avatar does not exist' do
    kata = make_kata
    refute katas.avatar_exists?(kata.id, 'lion')
    assert_equal [], kata.avatars.started.keys
  end

  test '16F7BB',
  'started avatar exists' do
    kata = make_kata
    assert_equal [], kata.avatars.started.keys
    kata.start_avatar(['lion'])
    assert_equal ['lion'], kata.avatars.started.keys
    assert katas.avatar_exists?(kata.id, 'lion')
  end

  #- - - - - - - - - - - - - - - -
  # avatar_increments
  #- - - - - - - - - - - - - - - -

  test '83EF2E',
  'started avatar has empty increments before any tests run' do
    kata = make_kata
    lion = kata.start_avatar(['lion'])
    incs = katas.avatar_increments(kata.id, 'lion')
    assert_equal [], incs
  end

  #- - - - - - - - - - - - - - - -
  # avatar_ran_tests
  #- - - - - - - - - - - - - - - -

  test '89817A',
  'after avatar_tested() one more increment' do
    kata = make_kata
    lion = kata.start_avatar(['lion'])
    maker = DeltaMaker.new(lion)
    now = time_now
    lion.tested(maker.visible_files, now, output='xx', 'amber')
    incs = katas.avatar_increments(kata.id, 'lion')
    assert_equal [{
      'colour' => 'amber',
      'time' => now,
      'number' => 1
    }], incs
  end

  #- - - - - - - - - - - - - - - -
  # paths
  #- - - - - - - - - - - - - - - -

  test 'B55710',
  'katas-path has correct format when set with trailing slash' do
    path = '/tmp/folder'
    set_katas_root(path + '/')
    assert_equal path, katas.path
    assert correct_path_format?(katas.path)
  end

  #- - - - - - - - - - - - - - - -

  test 'B2F787',
  'katas-path has correct format when set without trailing slash' do
    path = '/tmp/folder'
    set_katas_root(path)
    assert_equal path, katas.path
    assert correct_path_format?(katas.path)
  end

  #- - - - - - - - - - - - - - - -

  test '6F3999',
  'kata-path has correct format' do
    kata = make_kata
    assert correct_path_format?(katas.kata_path(kata.id))
  end

  #- - - - - - - - - - - - - - - -

  test '1E4B7A',
  'kata-path is split ala git' do
    kata = make_kata
    split = kata.id[0..1] + '/' + kata.id[2..-1]
    assert katas.kata_path(kata.id).include?(split)
  end

  #- - - - - - - - - - - - - - - -

  test '2ED22E',
  'avatar-path has correct format' do
    kata = make_kata
    avatar = kata.start_avatar(Avatars.names)
    assert correct_path_format?(katas.avatar_path(kata.id, avatar.name))
  end

  #- - - - - - - - - - - - - - - -

  test 'B7E4D5',
  'sandbox-path has correct format' do
    kata = make_kata
    avatar = kata.start_avatar(Avatars.names)
    sandbox_path = katas.sandbox_path(kata.id, avatar.name)
    assert correct_path_format?(sandbox_path)
    assert sandbox_path.include?('sandbox')
  end

  #- - - - - - - - - - - - - - - -
  #- - - - - - - - - - - - - - - -

  test 'CE9083',
  'make_kata saves manifest in kata dir' do
    kata = make_kata
    assert disk[katas.kata_path(kata.id)].exists?('manifest.json')
  end

  #- - - - - - - - - - - - - - - -

  test 'E4EB88',
  'a started avatar is git configured with single quoted user.name/email' do
    kata = make_kata
    salmon = kata.start_avatar(['salmon'])
    assert_log_include?("git config user.name 'salmon_#{kata.id}'")
    assert_log_include?("git config user.email 'salmon@cyber-dojo.org'")
  end

  #- - - - - - - - - - - - - - - -

  test '8EF1A3',
  'sandbox_save(... delta[:new] ...) files are git add.ed' do
    kata = make_kata
    @avatar = kata.start_avatar
    new_filename = 'ab.c'
    maker = DeltaMaker.new(@avatar)
    maker.new_file(new_filename, new_content = 'content for new file')

    git_evidence = "git add '#{new_filename}'"
    refute_log_include?(pathed(git_evidence))

    kata.katas.sandbox_save(kata.id, @avatar.name, maker.delta, maker.visible_files)

    assert_log_include?(pathed(git_evidence))
    assert_file new_filename, new_content
  end

  #- - - - - - - - - - - - - - - -

  test 'A66E09',
  'sandbox_save(... delta[:deleted] ...) files are git rm.ed' do
    kata = make_kata
    @avatar = kata.start_avatar
    maker = DeltaMaker.new(@avatar)
    maker.delete_file('makefile')

    git_evidence = "git rm 'makefile'"
    refute_log_include?(pathed(git_evidence))

    kata.katas.sandbox_save(kata.id, @avatar.name, maker.delta, maker.visible_files)

    assert_log_include?(pathed(git_evidence))
    refute maker.visible_files.keys.include? 'makefile'
  end

  #- - - - - - - - - - - - - - - -

  test '0BF880',
  'sandbox_save(... delta[:changed] ... files are not re git add.ed' do
    kata = make_kata
    avatar = kata.start_avatar
    maker = DeltaMaker.new(avatar)
    maker.change_file('makefile', 'sdsdsd')
    kata.katas.sandbox_save(kata.id, avatar.name, maker.delta, maker.visible_files)
    #??
  end

  #- - - - - - - - - - - - - - - -

  test '2D9F15',
  'sandbox dir is initially created' do
    kata = make_kata
    hippo = kata.start_avatar(['hippo'])
    assert disk[katas.sandbox_path(kata.id, 'hippo')].exists?
  end

  #- - - - - - - - - - - - - - - -
  # tags
  #- - - - - - - - - - - - - - - -

  test 'C42CB0',
  'tag_visible_files' do
    kata = make_kata
    hippo = kata.start_avatar(['hippo'])
    visible_files = katas.tag_visible_files(kata.id, 'hippo', tag=0)
    assert 6, visible_files.length
    assert visible_files.keys.include? 'makefile'
  end

  test '2E6296',
  'tag_git_diff' do
    kata = make_kata
    hippo = kata.start_avatar(['hippo'])
    new_filename = 'ab.c'
    maker = DeltaMaker.new(hippo)
    maker.new_file(new_filename, new_content = 'content for new file')
    now = time_now
    hippo.tested(maker.visible_files, now, output='xx', 'amber')
    diff = katas.tag_git_diff(kata.id, 'hippo', was_tag=0, now_tag=1)
    assert diff.start_with? 'diff --git'
  end

  #- - - - - - - - - - - - - - - -

  test '4C08A1',
  'start_avatar on multiple threads doesnt start the same avatar twice' do
    20.times do
      kata = make_kata
      started = []
      size = 4
      animals = Avatars.names[0...size].shuffle
      threads = Array.new(size * 2)
      names = Array.new(size * 2)
      threads.size.times { |i|
        threads[i] = Thread.new {
          avatar = kata.start_avatar(animals)
          names[i] = avatar.name unless avatar.nil?
        }
      }
      threads.size.times { |i| threads[i].join }
      names.compact!
      assert_equal animals.sort, names.sort
      assert_equal names.sort, kata.avatars.map(&:name).sort
    end
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - - -

  test 'A31DC1',
  'start_avatar on multiple processes doesnt start the same avatar twice' do
    20.times do
      kata = make_kata
      started = []
      size = 4
      animals = Avatars.names[0...size].shuffle
      pids = Array.new(size * 2)
      read_pipe, write_pipe = IO.pipe
      pids.size.times { |i|
        pids[i] = Process.fork {
          avatar = kata.start_avatar(animals)
          write_pipe.puts "#{avatar.name} " unless avatar.nil?
        }
      }
      pids.each { |pid| Process.wait(pid) }
      write_pipe.close
      names = read_pipe.read.split
      read_pipe.close
      assert_equal animals.sort, names.sort
      assert_equal names.sort, kata.avatars.map(&:name).sort
    end
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - - -

  private

  include TimeNow

  def correct_path_format?(path)
    ends_in_slash = path.end_with?('/')
    has_doubled_separator = path.scan('/' * 2).length != 0
    !ends_in_slash && !has_doubled_separator
  end

  def assert_file(filename, expected)
    actual = disk[katas.sandbox_path(@avatar.kata.id, @avatar.name)].read(filename)
    assert_equal expected, actual, 'saved_to_sandbox'
  end

  def assert_log_include?(command)
    assert log.include?(command), lines_of(log)
  end

  def refute_log_include?(command)
    refute log.include?(command), log.to_s
  end

  def lines_of(log)
    log.messages.join("\n")
  end

  def pathed(command)
    sandbox_path = katas.sandbox_path(@avatar.kata.id, @avatar.name)
    "cd #{sandbox_path} && #{command}"
  end

end
