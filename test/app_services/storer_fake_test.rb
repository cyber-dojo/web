require_relative 'app_services_test_base'
require_relative '../../app/services/storer_fake'
require_relative '../../app/models/avatars'

class StorerFakeTest < AppServicesTestBase

  def self.hex_prefix
    '9D375C'
  end

  def hex_setup
    set_differ_class('NotUsed')
    set_storer_class('StorerFake')
    set_runner_class('NotUsed')
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - -

  test 'EEE',
    'path is off /tmp to ensure read-write access' do
    refute_nil storer.path
    assert storer.path.start_with? '/tmp/'
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - -
  # kata_exists? avatar_exists? never raise
  # - - - - - - - - - - - - - - - - - - - - - - - - - -

  test '0CA',
  'kata_exists is false when kata-id is valid but does not exist' do
    refute storer.kata_exists?(kata_id)
  end

  # - - - - - - - - - - - - - - - - - - - - -

  test '0CB',
  'kata_exists is false when kata-id is invalid' do
    refute storer.kata_exists?(nil)
    refute storer.kata_exists?([])
    refute storer.kata_exists?('')
  end

  # - - - - - - - - - - - - - - - - - - - - -

  test '0CC',
  'avatar_exists is false when kata-id is invalid' do
    refute storer.avatar_exists?(nil, 'dolphin')
    refute storer.avatar_exists?([] , 'dolphin')
    refute storer.avatar_exists?('' , 'dolphin')
  end

  # - - - - - - - - - - - - - - - - - - - - -

  test '0CD',
  'avatar_exists is false when avatar-name is invalid' do
    kata_create
    refute storer.avatar_exists?(kata_id, nil)
    refute storer.avatar_exists?(kata_id, [])
    refute storer.avatar_exists?(kata_id, '')
    refute storer.avatar_exists?(kata_id, 'dolphin')
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - -
  # all other methods raise when kata_id is invalid
  # - - - - - - - - - - - - - - - - - - - - - - - - - -

  test '936',
  'kata_manifest(id) with invalid id raises' do
    error = assert_raises(ArgumentError) {
      storer.kata_manifest(invalid_kata_id)
    }
    assert_equal 'invalid kata_id', error.message
  end

  # - - - - - - - - - - - - - - - - - - - - -

  test '937',
  'avatars_started(id) with invalid id raises' do
    error = assert_raises(ArgumentError) {
      storer.avatars_started(invalid_kata_id)
    }
    assert_equal 'invalid kata_id', error.message
  end

  # - - - - - - - - - - - - - - - - - - - - -

  test '938',
  'avatar_start(id) with invalid id raises' do
    error = assert_raises(ArgumentError) {
      storer.avatar_start(invalid_kata_id, ['lion'])
    }
    assert_equal 'invalid kata_id', error.message
  end

  # - - - - - - - - - - - - - - - - - - - - -

  test '939',
  'avatar_increments(id) with invalid id raises' do
    error = assert_raises(ArgumentError) {
      storer.avatar_increments(invalid_kata_id, ['lion'])
    }
    assert_equal 'invalid kata_id', error.message
  end

  # - - - - - - - - - - - - - - - - - - - - -

  test '93A',
  'avatar_visible_files(id) with invalid id raises' do
    error = assert_raises(ArgumentError) {
      storer.avatar_visible_files('sdfsdf', 'lion')
    }
    assert_equal 'invalid kata_id', error.message
  end

  # - - - - - - - - - - - - - - - - - - - - -

  test '93B',
  'avatar_ran_tests(kata_id) with invalid kata_id raises' do
    args = [ invalid_kata_id, 'lion', any_starting_files={'cyber-dojo.sh'=>'pwd'} ]
    args += [ time_now, 'stdout', 'stderr', 'red' ]
    error = assert_raises(ArgumentError) {
      storer.avatar_ran_tests(*args)
    }
    assert_equal 'invalid kata_id', error.message
  end

  # - - - - - - - - - - - - - - - - - - - - -

  test '93C',
  'tag_visible_files(id) with invalid kata_id raises' do
    error = assert_raises(ArgumentError) {
      storer.tag_visible_files('sdfsdf', 'lion', tag=3)
    }
    assert_equal 'invalid kata_id', error.message
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  # kata_create() kata_manifest(id)
  #- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  test '3E8',
  'after kata_create() kata exists',
  'and manifest file holds kata properties',
  'but symbol-keys have become string-keys' do
    manifest = make_manifest
    refute storer.kata_exists?(kata_id)
    storer.kata_create(manifest)
    assert storer.kata_exists?(kata_id)
    expected = manifest
    actual = storer.kata_manifest(kata_id)
    assert_equal expected.keys.size, actual.keys.size
    expected.each do |key, value|
      assert_equal value, actual[key.to_s]
    end
  end

  # - - - - - - - - - - - - - - - - - - - - -

  test '3EB',
  'kata_manifest raises when kata-id does not exist' do
    error = assert_raises(ArgumentError) {
      storer.kata_manifest(kata_id)
    }
    assert_equal 'invalid kata_id', error.message
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  # katas_completed(id)
  #- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  test 'EA2',
  'katas_completed(id) is empty-string when id is less than 6 chars in length',
  'because trying to complete from a short id will waste time going through',
  'lots of candidates with the likely outcome of no unique result' do
    kata_create
    too_short = kata_id[0..4]
    assert_equal 5, too_short.length
    assert_equal '', storer.katas_completed(too_short)
  end

  # - - - - - - - - - - - - - - - - - - - - -

  test '34B',
  'katas_completed(id) completes when 6+ chars and 1 match' do
    kata_create
    (5..9).each do |hi|
      id = kata_id.downcase[0..hi]
      assert_equal hi+1, id.length
      assert id.length >= 6
      assert id.length <= 10
      assert_equal kata_id, storer.katas_completed(id)
    end
  end

  # - - - - - - - - - - - - - - - - - - - - -

  test '1A6',
  'katas_completed(id) is empty-string when no matches' do
    (0..9).each do |hi|
      id = kata_id.downcase[0..hi]
      assert_equal hi+1, id.length
      assert id.length >= 1
      assert id.length <= 10
      assert_equal '', storer.katas_completed(id)
    end
  end

  # - - - - - - - - - - - - - - - - - - - - -

  test '52E',
  'katas_completed(id=nil) is empty string' do
    assert_equal '', storer.katas_completed(nil)
  end

  # - - - - - - - - - - - - - - - - - - - - -

  test '91C',
  'katas_completed(id="") is empty string' do
    assert_equal '', storer.katas_completed('')
  end

  # - - - - - - - - - - - - - - - - - - - - -

  test 'B4F',
  'katas_completed(id) is empty-string when 6+ chars and more than one match' do
    id = '9D323B'
    stubbed_make_kata( first_id = id + '4F23')
    stubbed_make_kata(second_id = id + '9ED2')
    assert_equal '', storer.katas_completed(id)
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  # avatar_start(), avatars_started()
  #- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  test 'C02',
  'unstarted avatar does not exist' do
    kata_create
    assert_equal [], storer.avatars_started(kata_id)
  end

  # - - - - - - - - - - - - - - - - - - - - -

  test 'F7B',
  'started avatars exist' do
    kata_create
    assert_equal 'lion', storer.avatar_start(kata_id, ['lion'])
    assert_equal ['lion'], storer.avatars_started(kata_id)
    assert_equal 'salmon', storer.avatar_start(kata_id, ['lion','salmon'])
    assert_equal ['lion','salmon'].sort, storer.avatars_started(kata_id).sort
  end

  # - - - - - - - - - - - - - - - - - - - - -

  test 'B84',
  'each avatar can only start once' do
    kata_create
    Avatars.names.each do |name|
      assert_equal name, storer.avatar_start(kata_id, [name])
      assert_nil storer.avatar_start(kata_id, [name])
    end
  end

  # - - - - - - - - - - - - - - - - - - - - -

  test 'DE9',
  'when dojo is full, you cannot start another avatar' do
    kata_create
    Avatars.names.each do |name|
      assert_equal name, storer.avatar_start(kata_id, [name])
    end
    assert_nil storer.avatar_start(kata_id, ['lion'])
    assert_nil storer.avatar_start(kata_id, ['salmon'])
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  # kata_increments, avatar_increments, tag_visible_files
  #- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  test '48D',
  'avatar_increments raises when avatar_name is mal-formed' do
    kata_create
    error = assert_raises(ArgumentError) {
      storer.avatar_increments(kata_id, 'xxxx')
    }
    assert_equal 'invalid avatar_name', error.message
  end

  # - - - - - - - - - - - - - - - - - - - - -

  test '48E',
  'avatar_increments raises when avatar_name has not started' do
    kata_create
    error = assert_raises(ArgumentError) {
      storer.avatar_increments(kata_id, 'lion')
    }
    assert_equal 'invalid avatar_name', error.message
  end

  # - - - - - - - - - - - - - - - - - - - - -

  test '48F',
  "tag_visible_files for tag 0 is kata's starting files" do
    kata_create
    storer.avatar_start(kata_id, ['lion'])
    files0 = storer.kata_manifest(kata_id)['visible_files']
    assert_equal files0, storer.tag_visible_files(kata_id, 'lion', tag=0)
  end

  # - - - - - - - - - - - - - - - - - - - - -

  test '490',
  'tag_visible_files raises when tag is mal-formed' do
    kata_create
    storer.avatar_start(kata_id, ['lion'])
    error = assert_raises(ArgumentError) {
      storer.tag_visible_files(kata_id, 'lion', nil)
    }
    assert_equal 'invalid tag', error.message
  end

  # - - - - - - - - - - - - - - - - - - - - -

  test '491',
  'tag_visible_files raises when tag does not exist' do
    kata_create
    storer.avatar_start(kata_id, ['lion'])
    error = assert_raises(ArgumentError) {
      storer.tag_visible_files(kata_id, 'lion', 1)
    }
    assert_equal 'invalid tag', error.message
  end

  # - - - - - - - - - - - - - - - - - - - - -

  test '5BC',
  'after each ran_tests() a started avatar has',
  'a new traffic-light',
  'and new latest visible_files(plus output)',
  'and visible_file for each tag can be retrieved' do
    kata_create
    assert_equal({}, storer.kata_increments(kata_id))
    storer.avatar_start(kata_id, ['lion'])
    assert_equal({ 'lion' => [tag0] }, storer.kata_increments(kata_id))
    assert_equal [tag0], storer.avatar_increments(kata_id, 'lion')

    args = []
    args << kata_id
    args << 'lion'
    args << (files1 = kata.visible_files)
    args << (now1 = [2016,12,8, 8,3,23])
    args << (stdout = "Expected: 42\nActual: 54")
    args << (stderr = 'assertion failed')
    args << (colour1 = 'red')
    storer.avatar_ran_tests(*args)

    tag1 = { 'colour' => colour1, 'time' => now1, 'number' => 1 }
    files1['output'] = stdout + stderr
    assert_equal [tag0,tag1], storer.avatar_increments(kata_id, 'lion')
    assert_equal({ 'lion' => [tag0,tag1] }, storer.kata_increments(kata_id))
    assert_equal files1, storer.avatar_visible_files(kata_id, 'lion')
    assert_equal files1, storer.tag_visible_files(kata_id, 'lion', 1)

    args = []
    args << kata_id
    args << 'lion'
    files2 = kata.visible_files
    files2['hiker.rb'] = '...6*7...'
    args << files2
    args << (now2 = [2016,12,8, 9,54,20])
    args << (stdout = '1 runs, 1 assertions, 0 failures, 0 errors, 0 skips')
    args << (stderr = '')
    args << (colour2 = 'green')
    storer.avatar_ran_tests(*args)

    tag2 = { 'colour' => colour2, 'time' => now2, 'number' => 2 }
    assert_equal [tag0,tag1,tag2], storer.avatar_increments(kata_id, 'lion')
    assert_equal({ 'lion' => [tag0,tag1,tag2] }, storer.kata_increments(kata_id))
    files2['output'] = stdout + stderr
    assert_equal files2, storer.avatar_visible_files(kata_id, 'lion')
    assert_equal files1, storer.tag_visible_files(kata_id, 'lion', 1)
    assert_equal files2, storer.tag_visible_files(kata_id, 'lion', 2)
    json = storer.tags_visible_files(kata_id, 'lion', 1, 2)
    assert_equal files1, json['was_tag']
    assert_equal files2, json['now_tag']
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - -
  # tag_fork
  # - - - - - - - - - - - - - - - - - - - - - - - - - -

  test '04C',
  'tag_fork all arguments ok' do
    kata_create
    storer.avatar_start(kata_id, ['lion'])
    args = []
    args << kata_id
    args << 'lion'
    files = kata.visible_files
    files['forked.txt'] = 'hello world'
    args << files
    args << (now = [2017,12,28, 10,53,20])
    args << (stdout = '1 runs, 1 assertions, 0 failures, 0 errors, 0 skips')
    args << (stderr = '')
    args << (colour = 'green')
    storer.avatar_ran_tests(*args)
    now2 = [2017,12,28, 10,54,45]

    forked_id = 'C55885F816'
    id_generator.stub(forked_id)
    assert_equal forked_id, storer.tag_fork(kata_id, 'lion', -1, now2)
    files['output'] = stdout + stderr
    assert_equal files, storer.kata_manifest(forked_id)['visible_files']
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - -
  # tag_visible_files
  # - - - - - - - - - - - - - - - - - - - - - - - - - -

  test '171',
  'tag_visible_files when tag is -1 is the last tag' do
    kata_create
    storer.avatar_start(kata_id, ['lion'])
    args = []
    args << kata_id
    args << 'lion'
    files = kata.visible_files
    files['hiker.rb'] = '6*7'
    args << files
    args << (now = [2017,12,28, 10,53,20])
    args << (stdout = '1 runs, 1 assertions, 0 failures, 0 errors, 0 skips')
    args << (stderr = '')
    args << (colour = 'green')
    storer.avatar_ran_tests(*args)
    files['output'] = stdout + stderr
    assert_equal files, storer.tag_visible_files(kata_id, 'lion', -1)
  end

  # - - - - - - - - - - - - - - - - - - - - -

  test '172',
  'tag_visible_files raises when kata_id is invalid' do
    error = assert_raises(ArgumentError) {
      storer.tag_visible_files('xxx', 'dolphin', 20)
    }
    assert_equal 'invalid kata_id', error.message
  end

  # - - - - - - - - - - - - - - - - - - - - -

  test '173',
  'tag_visible_files raises when avatar_name is invalid' do
    kata_create
    error = assert_raises(ArgumentError) {
      storer.tag_visible_files(kata_id, 'xxx', 20)
    }
    assert_equal 'invalid avatar_name', error.message
  end

  # - - - - - - - - - - - - - - - - - - - - -

  test '174',
  'tag_visible_files raises when avatar_name is valid but unstarted' do
    kata_create
    error = assert_raises(ArgumentError) {
      storer.tag_visible_files(kata_id, 'lion', 20)
    }
    assert_equal 'invalid avatar_name', error.message
  end

  # - - - - - - - - - - - - - - - - - - - - -

  test '175',
  'tag_visible_files raises when tag is invalid' do
    kata_create
    storer.avatar_start(kata_id, ['lion'])
    error = assert_raises(ArgumentError) {
      storer.tag_visible_files(kata_id, 'lion', 1)
    }
    assert_equal 'invalid tag', error.message
  end

  private # = = = = = = = = = = = =

  def stubbed_make_kata(kata_id)
    id_generator.stub(kata_id)
    kata_create
  end

  def kata_create
    storer.kata_create(make_manifest)
  end

  def make_manifest
    manifest = starter.language_manifest('Ruby, MiniTest','Fizz_Buzz')
    manifest['created'] = creation_time
    manifest
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - -

  def invalid_kata_id
    'sdfsdfsdf'
  end

end
