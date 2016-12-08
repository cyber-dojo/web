
require_relative './../../lib/fake_disk'

class FakeStorer

  def initialize(parent)
    @parent = parent
    @disk = FakeDisk.new(self)
  end

  attr_reader :parent

  def path
    @path ||= env_var.value('katas_root')
  end

  # - - - - - - - - - - - - - - - - - - - - - - - -
  # Katas
  # - - - - - - - - - - - - - - - - - - - - - - - -

  def completed(id)
    # Used only in enter_controller/check
    # If at least 6 characters of the id are provided attempt to complete
    # it into the full 10 character id. Doing completion with fewer characters
    # would likely result in a lot of disk activity and no unique outcome.
    # Also, if completion was attempted for a very short id (say 3 characters)
    # it would provide a way for anyone to find the full id of a cyber-dojo
    # and potentially interfere with a live session.
    if !id.nil? && id.length >= 6
      # outer-dir has 2-characters
      outer_dir = disk[path + '/' + outer(id)]
      if outer_dir.exists?
        # inner-dir has 8-characters
        dirs = outer_dir.each_dir.select { |inner_dir| inner_dir.start_with?(inner(id)) }
        id = outer(id) + dirs[0] if dirs.length == 1
      end
    end
    id || ''
  end

  def completions(outer_dir)
    # for Batch-Method iteration over large number of katas...
    # (0..255).map{|n| '%02X' % n}.each do |outer|
    #   storer.ids_for(outer).each do |inner|
    #     ids << (outer + inner)
    #   end
    # end
    return [] unless disk[path + '/' + outer_dir].exists?
    disk[path + '/' + outer_dir].each_dir.collect { |dir| dir }
  end

  # - - - - - - - - - - - - - - - - - - - - - - - -
  # Kata
  # - - - - - - - - - - - - - - - - - - - - - - - -

  def kata_exists?(id)
    valid?(id) && kata_dir(id).exists?
  end

  def create_kata(manifest)
    # a kata's id has 10 hex chars. This gives 16^10 possibilities
    # which is 1,099,511,627,776 which is big enough to not
    # need to check that a kata with the id already exists.
    dir = kata_dir(manifest['id'])
    dir.make
    dir.write_json(manifest_filename, manifest)
  end

  # - - - - - - - - - - - - - - - -

  def kata_manifest(id)
    kata_dir(id).read_json(manifest_filename)
  end

  def kata_started_avatars(id)
    started = kata_dir(id).each_dir.collect { |name| name }
    started & Avatars.names
  end

  def kata_start_avatar(id, avatar_names)
    # Needs to be atomic otherwise two laptops in the same practice session
    # could start as the same animal. This relies on mkdir being atomic on
    # a (non NFS) POSIX file system.
    valid_names = avatar_names & Avatars.names
    # Don't do the & with operands swapped - you lose randomness
    name = valid_names.detect { |name| avatar_dir(id, name).make }
    if name.nil?
      return nil
    else
      write_avatar_increments(id, name, [])
      return name
    end
  end

  # - - - - - - - - - - - - - - - - - - - - - - - -
  # Avatar
  # - - - - - - - - - - - - - - - - - - - - - - - -

  def avatar_exists?(id, name)
    avatar_dir(id, name).exists?
  end

  def avatar_increments(id, name)
    avatar_dir(id, name).read_json(increments_filename)
  end

  def avatar_visible_files(id, name)
    rags = avatar_increments(id, name)
    tag = rags[-1]['number']
    tag_visible_files(id, name, tag)
  end

  def avatar_ran_tests(id, name, delta, files, now, output, colour)
    rags = avatar_increments(id, name)
    tag = rags.length + 1
    rags << { 'colour' => colour, 'time' => now, 'number' => tag }
    write_avatar_increments(id, name, rags)

    files = files.clone
    files['output'] = output
    write_tag_manifest(id, name, tag, files)
  end

  # - - - - - - - - - - - - - - - - - - - - - - - -
  # Tag
  # - - - - - - - - - - - - - - - - - - - - - - - -

  def tag_visible_files(id, name, tag)
    # retrieve all the files in one go
    tag_dir(id, name, tag).read_json(manifest_filename)
  end

  private

  attr_reader :disk

  include IdSplitter

  def kata_path(id)
    path + '/' + outer(id) + '/' + inner(id)
  end

  def avatar_path(id, name)
    kata_path(id) + '/' + name
  end

  def tag_path(id, name, tag)
    avatar_path(id, name) + '/' + tag.to_s
  end

  # - - - - - - - - - - - - - - - -

  def kata_dir(id)
    disk[kata_path(id)]
  end

  def avatar_dir(id, name)
    disk[avatar_path(id, name)]
  end

  def tag_dir(id, name, tag)
    disk[tag_path(id, name, tag)]
  end

  # - - - - - - - - - - - - - - - -

  def valid?(id)
    id.class.name == 'String' &&
      id.length == 10 &&
        id.chars.all? { |char| hex?(char) }
  end

  def hex?(char)
    '0123456789ABCDEF'.include?(char)
  end

  # - - - - - - - - - - - - - - - -

  def write_avatar_increments(id, name, increments)
    avatar_dir(id, name).write_json(increments_filename, increments)
  end

  def write_tag_manifest(id, name, tag, files)
    dir = tag_dir(id, name, tag)
    dir.make
    dir.write_json(manifest_filename, files)
  end

  # - - - - - - - - - - - - - - - -

  def increments_filename
    # Each avatar's increments stores a cache of colours and time-stamps
    # for all the avatar's [test]s. Helps optimize traffic-lights views.
    'increments.json'
  end

  def manifest_filename
    # Each kata's manifest stores the kata's meta information
    # such as the chosen language, tests, exercise.
    # Each avatar's manifest stores a cache of the avatar's
    # current visible files [filenames and contents].
    'manifest.json'
  end

  include NearestAncestors

  def env_var; nearest_ancestors(:env_var); end

end

