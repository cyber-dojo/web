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

  def completed(id)
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
    return [] unless disk[path + '/' + outer_dir].exists?
    disk[path + '/' + outer_dir].each_dir.collect { |dir| dir }
  end

  # - - - - - - - - - - - - - - - - - - - - - - - -

  def kata_exists?(id)
    valid?(id) && kata_dir(id).exists?
  end

  def create_kata(manifest)
    dir = kata_dir(manifest[:id])
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

  def avatar_exists?(id, name)
    avatar_dir(id, name).exists?
  end

  def avatar_increments(id, name)
    avatar_dir(id, name).read_json(increments_filename)
  end

  def avatar_visible_files(id, name)
    rags = avatar_increments(id, name)
    tag = rags == [] ? 0 : rags[-1]['number']
    tag_visible_files(id, name, tag)
  end

  def avatar_ran_tests(id, name, _delta, files, now, output, colour)
    rags = avatar_increments(id, name)
    tag = rags.length + 1
    rags << { 'colour' => colour, 'time' => now, 'number' => tag }
    write_avatar_increments(id, name, rags)

    files = files.clone
    files['output'] = output
    write_tag_manifest(id, name, tag, files)
  end

  # - - - - - - - - - - - - - - - - - - - - - - - -

  def tag_visible_files(id, name, tag)
    if tag == 0
      kata_manifest(id)['visible_files']
    else
      tag_dir(id, name, tag).read_json(manifest_filename)
    end
  end

  private

  attr_reader :disk

  include IdSplitter

  def   kata_path(id); path + '/' + outer(id) + '/' + inner(id); end
  def avatar_path(id, name); kata_path(id) + '/' + name; end
  def    tag_path(id, name, tag); avatar_path(id, name) + '/' + tag.to_s; end

  def   kata_dir(id); disk[kata_path(id)]; end
  def avatar_dir(id, name); disk[avatar_path(id, name)]; end
  def    tag_dir(id, name, tag); disk[tag_path(id, name, tag)]; end

  # - - - - - - - - - - - - - - - -

  def valid?(id)
    id.class.name == 'String' &&
      id.length == 10 &&
        id.chars.all? { |char| hex?(char) }
  end

  # - - - - - - - - - - - - - - - -

  def write_avatar_increments(id, name, increments)
    dir = avatar_dir(id, name)
    dir.write_json(increments_filename, increments)
  end

  def write_tag_manifest(id, name, tag, files)
    dir = tag_dir(id, name, tag)
    dir.make
    dir.write_json(manifest_filename, files)
  end

  # - - - - - - - - - - - - - - - -

  def hex?(char); '0123456789ABCDEF'.include?(char); end

  def increments_filename; 'increments.json'; end
  def   manifest_filename; 'manifest.json'; end

  include NearestAncestors

  def env_var; nearest_ancestors(:env_var); end

end
