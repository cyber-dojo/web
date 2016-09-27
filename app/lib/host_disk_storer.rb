
# See comments at end of file

class HostDiskStorer

  def initialize(parent)
    @parent = parent
  end

  attr_reader :parent

  def path
    @path ||= parent.env('katas_root')
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

  def ids_for(outer_dir)
    ids = []
    return [] unless disk[path + '/' + outer_dir].exists?
    disk[path + '/' + outer_dir].each_dir do |inner_dir|
      ids << inner_dir
    end
    ids
  end

  # - - - - - - - - - - - - - - - - - - - - - - - -
  # Kata
  # - - - - - - - - - - - - - - - - - - - - - - - -

  def kata_exists?(id)
    valid?(id) && disk[kata_path(id)].exists?
  end

  def create_kata(manifest)
    # a kata's id has 10 hex chars. This gives 16^10 possibilities
    # which is 1,099,511,627,776 which is big enough to not
    # need to check that a kata with the id already exists.
    dir = disk[kata_path(manifest[:id])]
    dir.make
    dir.write_json(manifest_filename, manifest)
  end

  # - - - - - - - - - - - - - - - -

  def kata_manifest(id)
    disk[kata_path(id)].read_json(manifest_filename)
  end

  def kata_started_avatars(id)
    lines, _ = shell.cd_exec(kata_path(id), 'ls -F | grep / | tr -d /')
    lines.split("\n") & Avatars.names
  end

  def kata_start_avatar(id, avatar_names)
    # Needs to be atomic otherwise two laptops in the same practice session
    # could start as the same animal. This relies on mkdir being atomic on
    # a (non NFS) POSIX file system.
    # Don't do the & with operands swapped - you lose randomness
    valid_names = avatar_names & Avatars.names
    name = valid_names.detect do |valid_name|
      _, exit_status = shell.cd_exec(kata_path(id), "mkdir #{valid_name} > /dev/null #{stderr_2_stdout}")
      exit_status == shell.success
    end

    return nil if name.nil? # full!

    user_name = name + '_' + id
    user_email = name + '@cyber-dojo.org'
    git.setup(avatar_path(id, name), user_name, user_email)

    disk[sandbox_path(id, name)].make
    visible_files = kata_manifest(id)['visible_files']
    visible_files.each do |filename, content|
      disk[sandbox_path(id, name)].write(filename, content)
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
    disk[avatar_path(id, name)].exists?
  end

  def avatar_increments(id, name)
    # implicitly for current tag
    disk[avatar_path(id, name)].read_json(increments_filename)
  end

  def avatar_visible_files(id, name)
    # implicitly for current tag
    disk[avatar_path(id, name)].read_json(manifest_filename)
  end

  def avatar_ran_tests(id, name, files, now, output, colour)
    disk[sandbox_path(id, name)].write('output', output)
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

  include ExternalParentChainer
  include IdSplitter
  include StderrRedirect

  def sandbox_write(id, name, filename, content)
    disk[sandbox_path(id, name)].write(filename, content)
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
    disk[avatar_path(id, name)].write_json(manifest_filename, files)
  end

  def write_avatar_increments(id, name, increments)
    disk[avatar_path(id, name)].write_json(increments_filename, increments)
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

end

# - - - - - - - - - - - - - - - - - - - - - - - -
# The files+output from each [test] event are saved as
# a tag in a git repo associated with the kata+avatar.
# There are also writes associated with creating each
# kata and starting each avatar.
# - - - - - - - - - - - - - - - - - - - - - - -
# This class's methods holds all the reads/writes for these.
# It uses the cyber-dojo server's file-system [katas] folder.

# In this is *an* implementation...
#
# 1. cyber-dojo.sh can do an incremental make.
#    In this case, the date-time stamp of the source files
#    is important and you want untouched files to retain
#    their old date-time stamp. This means you need to save
#    only the changed files from each test event and you
#    need the unchanged files to still be where you left
#    them last time.
#
# 2. Creating the download page's tar file which includes all
#    the git repos of all the animals. This is obviously quite
#    trivial if the animals git repos have been updated every
#    test event.
# - - - - - - - - - - - - - - - - - - - - - - - -
# An alternative implementation could save the manifest containing
# the visible files for each test to a database. Then, to get a
# git diff it could do something like this...
#
#    o) create a temporary git repository
#    o) get the visible_files for was_tag
#    o) save the visible_files in the git repo
#    o) git tag and git commit
#    o) get the visible_files from now_tag
#    o) calculate the [was_tag,now_tag] delta between the visible_files
#    o) delete any deleted files from the git repo
#    o) save the visible_files int the git repo
#    o) git tag and git commit
#    o) do a git diff
#    o) delete the temporary git repository
#
# There is probably a library to do this in ram bypassing
# the need for a file-system completely.
# Note: This would make creation of the tar file for
# a whole cyber-dojo potentially very slow.
# - - - - - - - - - - - - - - - - - - - - - - - -
