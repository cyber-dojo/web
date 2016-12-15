
class Avatar

  def initialize(kata, name)
    # Does *not* validate.
    # All access to avatar object must come through dojo.katas[id].avatars[name]
    @kata = kata
    @name = name
  end

  # modifiers

  def test(delta, files)
    deleted_filenames = delta[:deleted]
    changed_files = {}
    delta[:new    ].each { |filename| changed_files[filename] = files[filename] }
    delta[:changed].each { |filename| changed_files[filename] = files[filename] }
    max_seconds = 10
    runner.run(kata.image_name, kata.id, name, deleted_filenames, changed_files, max_seconds)
  end

  def tested(files, at, output, colour)
    storer.avatar_ran_tests(kata.id, name, files, at, output, colour)
  end

  # queries

  attr_reader :kata, :name

  def parent
    kata
  end

  def active?
    # Players sometimes start an extra avatar solely to read the
    # instructions. I don't want these avatars appearing on the dashboard.
    # When forking a new kata you can enter as one animal to sanity check
    # it is ok (but not press [test])
    storer.avatar_exists?(kata.id, name) && !lights.empty?
  end

  def tags
    increments.map { |h| Tag.new(self, h) }
  end

  def lights
    tags.select(&:light?)
  end

  def visible_filenames
    visible_files.keys
  end

  def visible_files
    storer.avatar_visible_files(kata.id, name)
  end

  private

  def increments
    storer.avatar_increments(kata.id, name)
  end

  include NearestAncestors
  def storer; nearest_ancestors(:storer); end
  def runner; nearest_ancestors(:runner); end

end

# ------------------------------------------------------
# The inclusive lower bound for n in avatar.tags[n] is zero.
#
# The inclusive upper bound for n in avatar.tags[n] is
# always the number of traffic-lights.
#
# When an animal does a diff of [1] what is run is a diff
# between
#   avatar.tags[0].visible_files
#   avatar.tags[1].visible_files
# ------------------------------------------------------

