
class Avatar

  def initialize(kata, name)
    # Does *not* validate.
    # All access to avatar object must come through
    # dojo.katas[id].avatars[name]
    @kata = kata
    @name = name
  end

  # modifiers

  def test(delta, files, max_seconds, image_name = kata.image_name)
    new_files     = files.select { |filename| delta[:new    ].include? filename }
    changed_files = files.select { |filename| delta[:changed].include? filename }
    args = []
    args << image_name        # eg 'cyberdojofoundation/gcc_assert'
    args << kata.id           # eg 'FE8A79A264'
    args << name              # eg 'salmon'
    args << delta[:deleted]   # eg [ 'instructions' ]
    args << new_files.merge(changed_files) # eg { 'hiker.h' => ... 'hiker.c' => ... }
    args << max_seconds       # eg 10
    runner.run(*args)
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
    # instructions. I don't want these avatars appearing on the
    # dashboard. When forking a new kata you can enter as one
    # animal to sanity check it is ok (but not press [test])
    !lights.empty?
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
