require_relative 'app_lib_test_base'

class SmokeTest < AppLibTestBase

  def self.hex_prefix
    '98255E'
  end

  def hex_setup
    set_storer_class('StorerService')
    set_runner_class('RunnerService')
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - -
  # runner
  #- - - - - - - - - - - - - - - - - - - - - - - - - -

  smoke_test 'CD3',
  'smoke test runner-service raising' do
    set_storer_class('StorerFake')
    kata = make_language_kata
    runner.kata_old(kata.image_name, kata.id)
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - -

  smoke_test '102',
  'smoke test image_pulled?' do
    kata = make_language_kata({
      'display_name' => 'Python, unittest'
    })
    assert kata.runner_choice == 'stateless' # no need to do runner.kata_old
    refute runner.image_pulled? 'cyberdojo/non_existant', kata.id
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - -

  smoke_test '812',
  'smoke test runner-service colour is red-amber-green traffic-light' do
    kata = make_language_kata({
      'display_name' => 'C (gcc), assert'
    })
    runner.avatar_new(kata.image_name, kata.id, lion, starting_files)
    args = []
    args << kata.image_name
    args << kata.id
    args << lion
    args << (max_seconds = 10)
    args << (delta = {
      :deleted   => [],
      :new       => [],
      :changed   => starting_files.keys,
      :unchanged => []
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

  smoke_test '51A',
  'non-existant kata-id raises exception' do
    assert_equal 'StorerService', storer.class.name
    error = assert_raises (StandardError) {
      storer.kata_manifest(kata_id)
    }
    assert error.message.end_with?('invalid kata_id')
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - -

  smoke_test '301',
  'smoke test storer-service' do
    assert_equal 'StorerService', storer.class.name

    refute all_ids.include? kata_id
    refute storer.kata_exists?(kata_id)

    major = 'C (gcc)'
    minor = 'assert'
    exercise = 'Fizz_Buzz'
    manifest = starter.language_manifest(major,minor,exercise)
    manifest['id'] = kata_id
    manifest['created'] = creation_time
    storer.create_kata(manifest)

    assert storer.kata_exists?(kata_id)
    assert all_ids.include? kata_id

    assert_equal({}, storer.kata_increments(kata_id))
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
    args << (now = [2016,12,8, 8,3,23])
    args << (output = 'Assert failed: answer() == 42')
    args << (colour = 'red')
    storer.avatar_ran_tests(*args)

    tag1 = { 'colour' => colour, 'time' => now, 'number' => 1 }
    assert_equal({ lion => [tag0,tag1] }, storer.kata_increments(kata_id))
    assert_equal [tag0,tag1], storer.avatar_increments(kata_id, lion)

    files1['output'] = output
    assert_equal files1, storer.avatar_visible_files(kata_id, lion)

    json = storer.tags_visible_files(kata_id, lion, was_tag=0, now_tag=1)
    assert_equal files0, json['was_tag']
    assert_equal files1, json['now_tag']
  end

end
