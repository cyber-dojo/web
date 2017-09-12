require_relative 'app_lib_test_base'

class SmokeTest < AppLibTestBase

  def setup
    super
    set_storer_class('StorerService')
    set_runner_class('RunnerService')
    @katas = Katas.new(self)
  end

  attr_reader :katas

  # - - - - - - - - - - - - - - - - - - - - - - - - - -
  # differ
  # - - - - - - - - - - - - - - - - - - - - - - - - - -

  smoke_test '9823AB',
  'smoke test differ-service' do
    kata = make_kata
    kata.start_avatar([lion])
    args = []
    args << kata.id
    args << lion
    args << (files1 = starting_files)
    args << (now1 = [2016,12,8,8,3,23])
    args << (output = 'Assert failed: answer() == 42')
    args << (colour = 'red')
    storer.avatar_ran_tests(*args)
    actual = differ.diff(kata.id, lion, was_tag=0, now_tag=1)

    refute_nil actual['hiker.c']
    assert_equal({
      "type"=>"same", "line"=>"#include \"hiker.h\"", "number"=>1
    }, actual['hiker.c'][0])
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - -
  # runner
  #- - - - - - - - - - - - - - - - - - - - - - - - - -

  smoke_test '2BD23CD3',
  'smoke test runner-service raising' do
    assert_raises { runner.image_pulled?(nil, nil) }
    assert_raises { runner.image_pull(nil, nil) }
    assert_raises { runner.kata_new(nil, nil) }
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - -

  smoke_test '2BDF808102',
  'smoke test pulling' do
    kata = make_kata({
      'language' => 'Python-unittest',
      'id' => '2BDF808102'
    })
    assert kata.runner_choice == 'stateless' # no need to do runner.kata_old
    refute runner.image_pulled? 'cyberdojo/non_existant', kata.id
    image_name = 'cyberdojofoundation/gcc_assert'
    assert runner.image_pull kata.image_name, kata.id
    assert runner.image_pulled? kata.image_name, kata.id
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - -

  smoke_test '2BDAD80812',
  'smoke test runner-service colour is red-amber-green traffic-light' do
    kata = make_kata({
      'language' => 'C (gcc)-assert',
      'id' => '2BDAD80812'
    })
    runner.avatar_new(kata.image_name, kata.id, lion, starting_files)
    args = []
    args << kata.image_name
    args << kata.id
    args << lion
    args << (max_seconds = 10)
    args << (delta = {
      :deleted => [],
      :new     => [],
      :changed => starting_files.keys
    })
    args << starting_files
    begin
      stdout,stderr,status,colour = runner.run(*args)
      assert stderr.include?('[makefile:4: test.output] Aborted'), stderr
      assert stderr.include?('Assertion failed: answer() == 42'), stderr
      assert_equal 2, status
      assert_equal 'red', colour
    ensure
      runner.avatar_old(kata.image_name, kata.id, lion)
      runner.kata_old(kata.image_name, kata.id)
    end
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - -
  # storer
  # - - - - - - - - - - - - - - - - - - - - - - - - - -
  # In docker-compose.yml the storer service is setup with
  #     environment: [ CYBER_DOJO_KATAS_ROOT=/tmp/cyber-dojo/katas ]
  # It does *not* volume-mount the katas data-container.

  smoke_test 'C6DCD7451A',
  'non-existant kata-id raises exception' do
    kata_id = 'C6DCD7451A'
    error = assert_raises (StandardError) { storer.kata_manifest(kata_id) }
    assert error.message.end_with?('invalid kata_id')
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - -

  smoke_test 'C6DE6CD301',
  'smoke test storer-service' do
    kata_id = 'C6DE6CD301'
    assert_equal 'StorerService', storer.class.name

    assert_equal '/tmp/cyber-dojo/katas', storer.path

    refute all_ids.include? kata_id

    refute storer.kata_exists?(kata_id)
    manifest = make_manifest(kata_id)
    storer.create_kata(manifest)
    assert storer.kata_exists?(kata_id)

    assert all_ids.include? kata_id

    expected = manifest
    actual = storer.kata_manifest(kata_id)
    assert_equal expected.keys.size, actual.keys.size
    expected.each do |key, value|
      assert_equal value, actual[key.to_s]
    end
    assert_equal({}, storer.kata_increments(kata_id))
    assert_equal kata_id, storer.completed(kata_id[0..5])
    assert_equal [], storer.started_avatars(kata_id)

    refute storer.avatar_exists?(kata_id, lion)
    assert_equal lion, storer.start_avatar(kata_id, [lion])
    assert storer.avatar_exists?(kata_id, lion)

    assert_equal({ lion => [tag0] }, storer.kata_increments(kata_id))
    assert_equal [lion], storer.started_avatars(kata_id)
    files0 = storer.kata_manifest(kata_id)['visible_files']
    assert_equal files0, storer.tag_visible_files(kata_id, lion, tag=0)
    assert_equal [tag0], storer.avatar_increments(kata_id, lion)

    args = []
    args << kata_id
    args << lion
    args << (files1 = edited_files)
    args << (now = [2016,12,8,8,3,23])
    args << (output = 'Assert failed: answer() == 42')
    args << (colour = 'red')
    storer.avatar_ran_tests(*args)

    tag1 = { 'colour' => colour, 'time' => now, 'number' => 1 }
    assert_equal({ lion => [tag0,tag1] }, storer.kata_increments(kata_id))
    assert_equal [tag0,tag1], storer.avatar_increments(kata_id, lion)

    files1['output'] = output
    assert_equal files1, storer.avatar_visible_files(kata_id, lion)

    hash = storer.tags_visible_files(kata_id, lion, was_tag=0, now_tag=1)
    assert_equal files0, hash['was_tag']
    assert_equal files1, hash['now_tag']
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - -
  # zipper
  # - - - - - - - - - - - - - - - - - - - - - - - - - -

  smoke_test 'D66EBF',
  'smoke test zipper.zip' do
    error = assert_raises { zipper.zip(kata_id='') }
    assert error.message.end_with?('invalid kata_id'), error.message
  end

  smoke_test 'D66959',
  'smoke test zipper.zip_tag' do
    error = assert_raises { zipper.zip_tag(kata_id='', 'lion', 0) }
    assert error.message.end_with?('invalid kata_id'), error.message
  end

end
