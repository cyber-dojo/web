require_relative './../../lib/disk_fake'
require_relative './../models/avatars'
require 'json'

class StorerFake

  def initialize(_)
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
          id = outer(id) + dirs[0]
        end
      end
    end
    id || ''
  end

  def completions(outer_dir)
    unless disk[dir_join(path, outer_dir)].exists?
      return []
    end
    disk[dir_join(path, outer_dir)].each_dir.collect { |dir| dir }
  end

  # - - - - - - - - - - - - - - - - - - - - - - - -

  def kata_exists?(kata_id)
    valid_id?(kata_id) && kata_dir(kata_id).exists?
  end

  def create_kata(manifest)
    json = JSON.unparse(manifest)
    id = manifest['id']
    assert_valid_id(id)
    refute_kata_exists(id)
    dir = kata_dir(id)
    dir.make
    dir.write(manifest_filename, json)
  end

  def kata_manifest(kata_id)
    assert_kata_exists(kata_id)
    dir = kata_dir(kata_id)
    json = dir.read(manifest_filename)
    JSON.parse(json)
  end

  def kata_increments(kata_id)
    Hash[started_avatars(kata_id).map { |name|
      [name, avatar_increments(kata_id, name)]
    }]
  end

  # - - - - - - - - - - - - - - - -

  def avatar_exists?(kata_id, avatar_name)
    valid_id?(kata_id) &&
      valid_avatar?(avatar_name) &&
        avatar_dir(kata_id, avatar_name).exists?
  end

  def start_avatar(kata_id, avatar_names)
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

  def started_avatars(kata_id)
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

  def avatar_visible_files(kata_id, avatar_name)
    assert_kata_exists(kata_id)
    assert_avatar_exists(kata_id, avatar_name)
    rags = read_avatar_increments(kata_id, avatar_name)
    tag = rags == [] ? 0 : rags[-1]['number']
    tag_visible_files(kata_id, avatar_name, tag)
  end

  # - - - - - - - - - - - - - - - - - - - - - - - -

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

  # - - - - - - - - - - - - - - - -

  def refute_kata_exists(kata_id)
    if kata_exists?(kata_id)
      fail invalid('kata_id')
    end
  end

  def assert_kata_exists(kata_id)
    unless kata_exists?(kata_id)
      fail invalid('kata_id')
    end
  end

  def assert_valid_id(kata_id)
    unless valid_id?(kata_id)
      fail invalid('kata_id')
    end
  end

  def valid_id?(kata_id)
    kata_id.class.name == 'String' &&
      kata_id.length == 10 &&
        kata_id.chars.all? { |char| hex?(char) }
  end

  def hex?(char)
    '0123456789ABCDEF'.include?(char)
  end

  def kata_dir(kata_id)
    disk[kata_path(kata_id)]
  end

  def kata_path(kata_id)
    dir_join(path, outer(kata_id), inner(kata_id))
  end

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

  def all_avatars_names
    Avatars.names
  end

  include IdSplitter

  def disk
    @@disk
  end

end
