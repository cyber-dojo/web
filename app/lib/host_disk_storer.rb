
# See comments at end of file

class HostDiskStorer

  def initialize(parent)
    @parent = parent
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
    # Needs to be atomic otherwise two laptops in the same practice session
    # could start as the same animal. This relies on mkdir being atomic on
    # a (non NFS) POSIX file system.
    valid_names = avatar_names & Avatars.names
    # Don't do the & with operands swapped - you lose randomness
    name = valid_names.detect { |name| avatar_dir(id, name).make }
    return nil if name.nil? # full!

    user_name = name + '_' + id
    user_email = name + '@cyber-dojo.org'
    git.setup(avatar_path(id, name), user_name, user_email)

    sandbox_dir(id, name).make
    visible_files = kata_manifest(id)['visible_files']
    visible_files.each do |filename, content|
      sandbox_dir(id, name).write(filename, content)
      git.add(sandbox_path(id, name), filename)
    end

    write_avatar_manifest(id, name, visible_files)
    git.add(avatar_path(id, name), manifest_filename)

    write_avatar_increments(id, name, [])
    git.add(avatar_path(id, name), increments_filename)

    git.commit(avatar_path(id, name), tag=0)

    name
  end

  # - - - - - - - - - - - - - - - - - - - - - - - -
  # Avatar
  # - - - - - - - - - - - - - - - - - - - - - - - -

  def avatar_exists?(id, name)
    avatar_dir(id, name).exists?
  end

  def avatar_increments(id, name)
    # implicitly for current (latest) tag
    avatar_dir(id, name).read_json(increments_filename)
  end

  def avatar_visible_files(id, name)
    # implicitly for current (latest) tag
    avatar_dir(id, name).read_json(manifest_filename)
  end

  def avatar_ran_tests(id, name, delta, files, now, output, colour)
    # TODO: making sandbox_save private will break tests in
    #       test/app_lib/host_disk_storer_test.rb
    sandbox_save(id, name, delta, files)
    sandbox_dir(id, name).write('output', output)
    files['output'] = output
    write_avatar_manifest(id, name, files)
    # update the Red/Amber/Green increments
    rags = avatar_increments(id, name)
    tag = rags.length + 1
    rags << { 'colour' => colour, 'time' => now, 'number' => tag }
    write_avatar_increments(id, name, rags)
    # git-commit the manifest, increments, and visible-files
    git.commit(avatar_path(id, name), tag)
  end

  # - - - - - - - - - - - - - - - - - - - - - - - -
  # Sandbox
  # - - - - - - - - - - - - - - - - - - - - - - - -

  def sandbox_save(id, name, delta, files)
    # Unchanged files are *not* re-saved.
    delta[:deleted].each do |filename|
      git.rm(sandbox_path(id, name), filename)
    end
    delta[:new].each do |filename|
      sandbox_write(id, name, filename, files[filename])
      git.add(sandbox_path(id, name), filename)
    end
    delta[:changed].each do |filename|
      sandbox_write(id, name, filename, files[filename])
    end
  end

  # - - - - - - - - - - - - - - - - - - - - - - - -
  # Tag
  # - - - - - - - - - - - - - - - - - - - - - - - -

  def tag_visible_files(id, name, tag)
    # retrieve all the files in one go
    JSON.parse(git.show(avatar_path(id, name), "#{tag}:#{manifest_filename}"))
  end

  # - - - - - - - - - - - - - - - - - - - - - - - -
  # Path
  # - - - - - - - - - - - - - - - - - - - - - - - -

  def kata_path(id)
    path + '/' + outer(id) + '/' + inner(id)
  end

  def avatar_path(id, name)
    kata_path(id) + '/' + name
  end

  def sandbox_path(id, name)
    # An avatar's source files are _not_ held in its own folder
    # (but in the it's sandbox folder) because its own folder
    # is used for the manifest.json and increments.json files.
    avatar_path(id, name) + '/sandbox'
  end

  private

  include IdSplitter
  include NearestAncestors

  def kata_dir(id)
    disk[kata_path(id)]
  end

  def avatar_dir(id, name)
    disk[avatar_path(id, name)]
  end

  def sandbox_dir(id, name)
    disk[sandbox_path(id, name)]
  end

  def sandbox_write(id, name, filename, content)
    sandbox_dir(id, name).write(filename, content)
  end

  def valid?(id)
    id.class.name == 'String' &&
      id.length == 10 &&
        id.chars.all? { |char| hex?(char) }
  end

  def hex?(char)
    '0123456789ABCDEF'.include?(char)
  end

  def write_avatar_manifest(id, name, files)
    avatar_dir(id, name).write_json(manifest_filename, files)
  end

  def write_avatar_increments(id, name, increments)
    avatar_dir(id, name).write_json(increments_filename, increments)
  end

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

  def env_var; nearest_ancestors(:env_var); end
  def disk; nearest_ancestors(:disk); end
  def git; nearest_ancestors(:git); end

end

# - - - - - - - - - - - - - - - - - - - - - - - -
# There are writes associated with creating each
# kata and starting each avatar.
# The files+output from each [test] event are saved as
# a tag in a git repo associated with the kata+avatar.
# The choice to use git is *an* implementation. It makes
# it easy to do the download page's tar file which includes all
# the git repos of all the animals.
# - - - - - - - - - - - - - - - - - - - - - - -
# An alternative implementation could save the manifest containing
# the visible files but not do a git commit for each test event.
# For example, the manifest.json for tag 15 would be saved to
# katas/...ID.../lion/15/manifest.json
# Then, the downloader could recreate the git repos on the fly
# in tmp/
# There is probably a library to do this in ram bypassing
# the need for a file-system completely.
# Note: This would potentially make creation of the tar file
# for a whole cyber-dojo potentially very slow.
# - - - - - - - - - - - - - - - - - - - - - - - -
