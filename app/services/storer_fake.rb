require_relative 'disk_fake'
require_relative './../models/avatars'
require 'json'

class StorerFake

  def initialize(external)
    @external = external
    # This is @@disk and not @disk so that it behaves as
    # a real disk on tests that run across multiple threads
    # (as some app-controller tests do).
    @@disk ||= DiskFake.new(self)
    # Isolate tests from each other.
    test_id = ENV['CYBER_DOJO_TEST_ID']
    @path = "/tmp/cyber-dojo/#{test_id}/katas"
  end

  attr_reader :path

  # - - - - - - - - - - - - - - - - - - - - - - - -
  # completion(s)
  # - - - - - - - - - - - - - - - - - - - - - - - -

  def completed(id)
    if !id.nil? && id.length >= 6
      # outer-dir has 2-characters
      outer_dir = disk[dir_join(path, outer(id))]
      if outer_dir.exists?
        # inner-dir has 8-characters
        dirs = outer_dir.each_dir.select { |inner_dir|
          inner_dir.start_with?(inner(id))
        }
        if dirs.length == 1
          return outer(id) + dirs[0]
        end
      end
    end
    ''
  end

  # - - - - - - - - - - - - - - - - - - - - - - - -
  # kata
  # - - - - - - - - - - - - - - - - - - - - - - - -

  def valid_id?(kata_id)
    partial_id?(kata_id) && kata_id.length == 10
  end

  # - - - - - - - - - - - - - - - - - - - - - - - -

  def kata_exists?(kata_id)
    valid_id?(kata_id) && kata_dir(kata_id).exists?
  end

  # - - - - - - - - - - - - - - - - - - - - - - - -

  def kata_create(manifest)
    kata_id = id_generator.generate
    #assert valid_id?(kata_id)
    #refute kata_exists?(kata_id)
    manifest['id'] = kata_id
    dir = kata_dir(kata_id)
    dir.make
    dir.write(manifest_filename, JSON.unparse(manifest))
    kata_id
  end

  # - - - - - - - - - - - - - - - - - - - - - - - -

  def kata_manifest(kata_id)
    assert_kata_exists(kata_id)
    dir = kata_dir(kata_id)
    json = dir.read(manifest_filename)
    JSON.parse(json)
  end

  # - - - - - - - - - - - - - - - - - - - - - - - -

  def kata_increments(kata_id)
    Hash[avatars_started(kata_id).map { |name|
      [name, avatar_increments(kata_id, name)]
    }]
  end

  # - - - - - - - - - - - - - - - -
  # avatar
  # - - - - - - - - - - - - - - - -

  def avatar_exists?(kata_id, avatar_name)
    valid_id?(kata_id) &&
      valid_avatar?(avatar_name) &&
        avatar_dir(kata_id, avatar_name).exists?
  end

  # - - - - - - - - - - - - - - - - - - - - - - - -

  def avatar_start(kata_id, avatar_names)
    assert_kata_exists(kata_id)
    # NB: Doing & with swapped args loses randomness!
    valid_names = avatar_names & all_avatars_names
    avatar_name = valid_names.detect { |name| avatar_dir(kata_id, name).make }
    if avatar_name.nil? # full!
      return nil
    end
    write_avatar_increments(kata_id, avatar_name, [])
    return avatar_name
  end

  # - - - - - - - - - - - - - - - - - - - - - - - -

  def avatars_started(kata_id)
    assert_kata_exists(kata_id)
    started = kata_dir(kata_id).each_dir.collect { |name| name }
    started & all_avatars_names
  end

  # - - - - - - - - - - - - - - - - - - - - - - - -

  def avatar_ran_tests(kata_id, avatar_name, files, now, output, colour)
    assert_kata_exists(kata_id)
    assert_avatar_exists(kata_id, avatar_name)
    increments = read_avatar_increments(kata_id, avatar_name)
    tag = increments.length + 1
    increments << { 'colour' => colour, 'time'   => now, 'number' => tag }
    write_avatar_increments(kata_id, avatar_name, increments)
    # don't alter caller's files argument
    files = files.clone
    files['output'] = output
    write_tag_files(kata_id, avatar_name, tag, files)
  end

  # - - - - - - - - - - - - - - - - - - - - - - - -

  def avatar_increments(kata_id, avatar_name)
    assert_kata_exists(kata_id)
    assert_avatar_exists(kata_id, avatar_name)
    tag0 =
      {
        'event'  => 'created',
        'time'   => kata_manifest(kata_id)['created'],
        'number' => 0
      }
    [tag0] + read_avatar_increments(kata_id, avatar_name)
  end

  # - - - - - - - - - - - - - - - - - - - - - - - -

  def avatar_visible_files(kata_id, avatar_name)
    assert_kata_exists(kata_id)
    assert_avatar_exists(kata_id, avatar_name)
    rags = read_avatar_increments(kata_id, avatar_name)
    tag = rags == [] ? 0 : rags[-1]['number']
    tag_visible_files(kata_id, avatar_name, tag)
  end

  # - - - - - - - - - - - - - - - - - - - - - - - -
  # tag
  # - - - - - - - - - - - - - - - - - - - - - - - -

  def tag_fork(kata_id, avatar_name, tag, now)
    visible_files = tag_visible_files(kata_id, avatar_name, tag)
    manifest = kata_manifest(kata_id)
    manifest['visible_files'] = visible_files
    manifest['created'] = now
    forked_id = kata_create(manifest)
    forked_id
  end

  def tag_visible_files(kata_id, avatar_name, tag)
    assert_kata_exists(kata_id)
    assert_avatar_exists(kata_id, avatar_name)
    assert_valid_tag(tag)
    tag = tag.to_i
    if tag == -1
      tag = avatar_increments(kata_id, avatar_name).size - 1
    end
    assert_tag_exists(kata_id, avatar_name, tag)
    if tag == 0
      kata_manifest(kata_id)['visible_files']
    else
      read_tag_files(kata_id, avatar_name, tag)
    end
  end

  # - - - - - - - - - - - - - - - - - - - - - - - -
  # tags
  # - - - - - - - - - - - - - - - - - - - - - - - -

  def tags_visible_files(kata_id, avatar_name, was_tag, now_tag)
    {
      'was_tag' => tag_visible_files(kata_id, avatar_name, was_tag),
      'now_tag' => tag_visible_files(kata_id, avatar_name, now_tag)
    }
  end

  private # = = = = = = = = = = = = = = =

  def write_avatar_increments(kata_id, avatar_name, increments)
    json = JSON.unparse(increments)
    dir = avatar_dir(kata_id, avatar_name)
    dir.write(increments_filename, json)
  end

  def read_avatar_increments(kata_id, avatar_name)
    dir = avatar_dir(kata_id, avatar_name)
    json = dir.read(increments_filename)
    JSON.parse(json)
  end

  def increments_filename
    'increments.json'
  end

  # - - - - - - - - - - - - - - - -

  def write_tag_files(kata_id, avatar_name, tag, files)
    json = JSON.unparse(files)
    dir = tag_dir(kata_id, avatar_name, tag)
    dir.make
    dir.write(manifest_filename, json)
  end

  def read_tag_files(kata_id, avatar_name, tag)
    dir = tag_dir(kata_id, avatar_name, tag)
    json = dir.read(manifest_filename)
    JSON.parse(json)
  end

  def manifest_filename
    'manifest.json'
  end

  # - - - - - - - - - - - - - - - - - - - - - - - -
  # id
  # - - - - - - - - - - - - - - - - - - - - - - - -

  def partial_id?(kata_id)
    kata_id.is_a?(String) &&
      kata_id.chars.all? { |char| hex?(char) }
  end

  def hex?(char)
    '0123456789ABCDEF'.include?(char)
  end

  # - - - - - - - - - - - - - - - - - - - - - - - -
  # kata
  # - - - - - - - - - - - - - - - - - - - - - - - -

  def assert_kata_exists(kata_id)
    unless kata_exists?(kata_id)
      fail invalid('kata_id')
    end
  end

  def kata_dir(kata_id)
    disk[kata_path(kata_id)]
  end

  def kata_path(kata_id)
    dir_join(path, outer(kata_id), inner(kata_id))
  end

  # - - - - - - - - - - - - - - - - - - - - - - - -
  # avatar
  # - - - - - - - - - - - - - - - - - - - - - - - -

  def assert_avatar_exists(kata_id, avatar_name)
    unless avatar_exists?(kata_id, avatar_name)
      fail invalid('avatar_name')
    end
  end

  def valid_avatar?(avatar_name)
    avatar_name.class.name == 'String' &&
      all_avatars_names.include?(avatar_name)
  end

  def avatar_dir(kata_id, avatar_name)
    disk[avatar_path(kata_id, avatar_name)]
  end

  def avatar_path(kata_id, avatar_name)
    dir_join(kata_path(kata_id), avatar_name)
  end

  def all_avatars_names
    Avatars.names
  end

  # - - - - - - - - - - - - - - - - - - - - - - - -
  # tag
  # - - - - - - - - - - - - - - - - - - - - - - - -

  def assert_tag_exists(kata_id, avatar_name, tag)
    assert_valid_tag(tag)
    unless tag_exists?(kata_id, avatar_name, tag)
      fail invalid('tag')
    end
  end

  def assert_valid_tag(tag)
    unless valid_tag?(tag)
      fail invalid('tag')
    end
  end

  def valid_tag?(tag)
    tag.is_a?(Integer) ||
      tag.to_s =~ /^-1/ ||
        tag.to_s =~ /^[0-9+]$/
  end

  def tag_exists?(kata_id, avatar_name, tag)
    # Has to work with old git-format and new non-git format
    0 <= tag && tag <= read_avatar_increments(kata_id, avatar_name).size
  end

  def tag_dir(kata_id, avatar_name, tag)
    disk[tag_path(kata_id, avatar_name, tag)]
  end

  def tag_path(kata_id, avatar_name, tag)
    dir_join(avatar_path(kata_id, avatar_name), tag.to_s)
  end

  # - - - - - - - - - - -

  def dir_join(*args)
    File.join(*args)
  end

  def invalid(message)
    ArgumentError.new("invalid #{message}")
  end

  # - - - - - - - - - - - - - - - -

  def outer(id)
    id.upcase[0..1]  # '35'
  end

  def inner(id)
    id.upcase[2..-1] # '6CDE70DB'
  end

  # - - - - - - - - - - - - - - - -

  def disk
    @@disk
  end

  def id_generator
    @external.id_generator
  end

end
