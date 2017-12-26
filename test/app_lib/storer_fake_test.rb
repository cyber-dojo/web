require_relative 'app_lib_test_base'
require_relative '../../app/lib/storer_fake'
require_relative '../../app/models/avatars'

class StorerFakeTest < AppLibTestBase

  def storer
    @storer ||= StorerFake.new(self)
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  test '9D355EEE',
    'path is off /tmp to ensure read-write access' do
    refute_nil storer.path
    assert storer.path.start_with? '/tmp/'
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - -
  # invalid_id on any method raises
  # TODO: the exceptions and messages should be
  # be the same as the StorerService.
  # - - - - - - - - - - - - - - - - - - - - - - - - - -

  test '9D3933',
  'create_kata with missing id raises' do
    manifest = make_manifest(nil)
    manifest.delete('id')
    error = assert_raises(ArgumentError) { storer.create_kata(manifest) }
    assert error.message.start_with?('StorerFake'), error.message
  end

  test '9D3934',
  'create_kata with an invalid id raises' do
    manifest = make_manifest(nil)
    manifest['id'] = invalid_id
    error = assert_raises(ArgumentError) {
      storer.create_kata(manifest)
    }
    assert_equal 'StorerFake:invalid id', error.message
  end

  test '9D3935',
  'create_kata with duplicate id raises' do
    kata_id = '9D39350001'
    manifest = make_manifest(kata_id)
    storer.create_kata(manifest)
    error = assert_raises(ArgumentError) {
      storer.create_kata(manifest)
    }
    assert_equal 'StorerFake:invalid id', error.message
  end

  test '9D3936',
  'kata_manifest(id) with invalid id raises' do
    error = assert_raises(ArgumentError) {
      storer.kata_manifest(invalid_id)
    }
    assert_equal 'StorerFake:invalid id', error.message
  end

  test '9D3937',
  'started_avatars(id) with invalid id raises' do
    error = assert_raises(ArgumentError) {
      storer.started_avatars(invalid_id)
    }
    assert_equal 'StorerFake:invalid id', error.message
  end

  test '9D3938',
  'start_avatar(id) with invalid id raises' do
    error = assert_raises(ArgumentError) {
      storer.start_avatar(invalid_id, [lion])
    }
    assert_equal 'StorerFake:invalid id', error.message
  end

  test '9D3939',
  'avatar_increments(id) with invalid id raises' do
    error = assert_raises(ArgumentError) {
      storer.avatar_increments(invalid_id, [lion])
    }
    assert_equal 'StorerFake:invalid id', error.message
  end

  test '9D393A',
  'avatar_visible_files(id) with invalid id raises' do
    error = assert_raises(ArgumentError) {
      storer.avatar_visible_files('sdfsdf', lion)
    }
    assert_equal 'StorerFake:invalid id', error.message
  end

  test '9D393B',
  'avatar_ran_tests(id) with invalid id raises' do
    args = [ 'sdsdfsdf', lion, starting_files ]
    args += [ time_now, 'output', 'red' ]
    error = assert_raises(ArgumentError) {
      storer.avatar_ran_tests(*args)
    }
    assert_equal 'StorerFake:invalid id', error.message
  end

  test '9D393C',
  'tag_visible_files(id) with invalid id raises' do
    error = assert_raises(ArgumentError) {
      storer.tag_visible_files('sdfsdf', lion, tag=3)
    }
    assert_equal 'StorerFake:invalid id', error.message
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  # create_kata()
  #- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  test '9D3603E8',
  'after create_kata() kata exists',
  'and manifest file holds kata properties',
  'but symbol-keys have become string-keys' do
    manifest = make_manifest(kata_id = '603E8BAEDF')
    storer.create_kata(manifest)
    expected = manifest
    actual = kata_manifest(kata_id)
    assert_equal expected.keys.size, actual.keys.size
    expected.each do |key, value|
      assert_equal value, actual[key.to_s]
    end
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  # completions(id)
  #- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  test '9D33DFAF',
  'each() yields empty array when there are no katas' do
    assert_equal [], all_ids
  end

  test '9D35A293',
  'each() yields one kata-id' do
    create_kata(kata_id = '9D35A29321')
    assert_equal [kata_id], all_ids
  end

  test '9D3F0C15',
  'each() yields two unrelated kata-ids' do
    create_kata(kata_id_1 = 'C56C6C4202')
    create_kata(kata_id_2 = 'DEB3E1325D')
    assert_equal [kata_id_1, kata_id_2].sort, all_ids.sort
  end

  test '9D329DFD',
  'each() yields several kata-ids with common first two characters' do
    create_kata(kata_id_1 = '9D329DFD34')
    create_kata(kata_id_2 = '9D5E889E04')
    create_kata(kata_id_3 = '9DF376ED91')
    assert_equal [kata_id_1, kata_id_2, kata_id_3].sort, all_ids.sort
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  # completed(id)
  #- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  test '9D342EA2',
  'completed(id) does not complete when id is less than 6 chars in length',
  'because trying to complete from a short id will waste time going through',
  'lots of candidates with the likely outcome of no unique result' do
    create_kata(kata_id = '9D342EA27E')
    too_short = kata_id[0..4]
    assert_equal 5, too_short.length
    assert_equal too_short, storer.completed(too_short)
  end

  test '9D30934B',
  'completed(id) completes when 6+ chars and 1 match' do
    create_kata(kata_id = '9D30934B7A')
    (5..9).each do |hi|
      id = kata_id.downcase[0..hi]
      assert_equal hi+1, id.length
      assert id.length >= 6
      assert id.length <= 10
      assert_equal kata_id, completed(id)
    end
  end

  test '9D3071A6',
  'completed(id) unchanged when no matches' do
    kata_id = '9D3071A629'
    (0..9).each do |hi|
      id = kata_id.downcase[0..hi]
      assert_equal hi+1, id.length
      assert id.length >= 1
      assert id.length <= 10
      assert_equal id, completed(id)
    end
  end

  test '9D3B652E',
  'completed(id=nil) is empty string' do
    assert_equal '', completed(nil)
  end

  test '9D3D391C',
  'completed(id="") is empty string' do
    assert_equal '', completed('')
  end

  test '9D323B4F',
  'completed(id) does not complete when 6+ chars and more than one match' do
    id = '9D323B'
    create_kata(kata_id_1 = id+'4F23')
    create_kata(kata_id_2 = id+'9ED2')
    assert_equal id, completed(id)
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  # start_avatar
  #- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  test '9D381C02',
  'unstarted avatar does not exist' do
    create_kata(kata_id = '9D381C0200')
    assert_equal [], started_avatars(kata_id)
  end

  test '9D316F7B',
  'started avatars exist' do
    create_kata(kata_id = '9D316F7B00')
    assert_equal lion, start_avatar(kata_id, [lion])
    assert_equal [lion], started_avatars(kata_id)
    assert_equal salmon, start_avatar(kata_id, [lion,salmon])
    assert_equal [lion,salmon].sort, started_avatars(kata_id).sort
  end

  test '9D3B0B84',
  'each avatar can only start once' do
    create_kata(kata_id = '9D3B0B84BA')
    Avatars.names.each do |name|
      assert_equal name, start_avatar(kata_id, [name])
      assert_nil start_avatar(kata_id, [name])
    end
  end

  test '9D35DDE9',
  'when dojo is full, you cannot start another avatar' do
    create_kata(kata_id = '9D35DDE924')
    Avatars.names.each do |name|
      assert_equal name, start_avatar(kata_id, [name])
    end
    assert_nil start_avatar(kata_id, [lion])
    assert_nil start_avatar(kata_id, [salmon])
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  # kata_increments, avatar_increments, tag_visible_files
  #- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  test '9D3FC48F',
  "tag_visible_files for tag 0 is kata's starting files" do
    create_kata(kata_id = '9D3FC48F03')
    start_avatar(kata_id, [lion])
    files0 = kata_manifest(kata_id)['visible_files']
    assert_equal files0, tag_visible_files(kata_id, lion, tag=0)
  end

  test '9D3A35BC',
  'after each ran_tests() a started avatar has',
  'a new traffic-light',
  'and new latest visible_files(plus output)',
  'and visible_file for each tag can be retrieved' do
    create_kata(kata_id = '9D3A35BCCF')
    assert_equal({}, kata_increments(kata_id))
    start_avatar(kata_id, [lion])
    assert_equal({ lion => [tag0] }, kata_increments(kata_id))
    assert_equal [tag0], avatar_increments(kata_id, lion)

    args = []
    args << kata_id
    args << lion
    args << (files1 = starting_files)
    args << (now1 = [2016,12,8,8,3,23])
    args << (output = 'Assert failed: answer() == 42')
    args << (colour1 = 'red')
    avatar_ran_tests(*args)

    tag1 = { 'colour' => colour1, 'time' => now1, 'number' => 1 }
    files1['output'] = output
    assert_equal [tag0,tag1], avatar_increments(kata_id, lion)
    assert_equal({ lion => [tag0,tag1] }, kata_increments(kata_id))
    assert_equal files1, avatar_visible_files(kata_id, lion)
    assert_equal files1, tag_visible_files(kata_id, lion, 1)

    args = []
    args << kata_id
    args << lion
    files2 = starting_files
    files2['hiker.c'] = '6*7';
    args << files2
    args << (now2 = [2016,12,8,9,54,20])
    args << (output = 'All tests passed')
    args << (colour2 = 'green')
    avatar_ran_tests(*args)

    tag2 = { 'colour' => colour2, 'time' => now2, 'number' => 2 }
    assert_equal [tag0,tag1,tag2], avatar_increments(kata_id, lion)
    assert_equal({ lion => [tag0,tag1,tag2] }, kata_increments(kata_id))
    files2['output'] = output
    assert_equal files2, avatar_visible_files(kata_id, lion)
    assert_equal files1, tag_visible_files(kata_id, lion, 1)
    assert_equal files2, tag_visible_files(kata_id, lion, 2)
    json = tags_visible_files(kata_id, lion, 1, 2)
    assert_equal files1, json['was_tag']
    assert_equal files2, json['now_tag']
  end

  private

  def invalid_id
    'sdfsdfsdf'
  end

  def create_kata(kata_id)
    manifest = make_manifest(kata_id)
    storer.create_kata(manifest)
  end

  def kata_manifest(kata_id)
    storer.kata_manifest(kata_id)
  end

  def kata_increments(kata_id)
    storer.kata_increments(kata_id)
  end

  def completed(id)
    storer.completed(id)
  end

  def start_avatar(kata_id, avatar_names)
    storer.start_avatar(kata_id, avatar_names)
  end

  def started_avatars(kata_id)
    storer.started_avatars(kata_id)
  end

  def avatar_increments(kata_id, avatar_name)
    storer.avatar_increments(kata_id, avatar_name)
  end

  def avatar_visible_files(kata_id, avatar_name)
    storer.avatar_visible_files(kata_id, avatar_name)
  end

  def avatar_ran_tests(kata_id, avatar_name, *args)
    storer.avatar_ran_tests(kata_id, avatar_name, *args)
  end

  def tag_visible_files(kata_id, avatar_name, tag)
    storer.tag_visible_files(kata_id, avatar_name, tag)
  end

  def tags_visible_files(kata_id, avatar_name, was_tag, now_tag)
    storer.tags_visible_files(kata_id, avatar_name, was_tag, now_tag)
  end

end
