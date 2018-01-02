
class Avatar

  def initialize(externals, kata, name)
    # Does *not* validate.
    @externals = externals
    @kata = kata
    @name = name
  end

  # modifiers

  def test(delta, files, max_seconds, image_name = kata.image_name)
    args = []
    args << image_name        # eg 'cyberdojofoundation/gcc_assert'
    args << kata.id           # eg 'FE8A79A264'
    args << name              # eg 'salmon'
    args << max_seconds       # eg 10
    args << delta
    args << files
    runner.run(*args)
  end

  def tested(files, at, output, colour)
    storer.avatar_ran_tests(kata.id, name, files, at, output, colour)
  end

  # queries

  attr_reader :kata, :name

  def active?
    # Players sometimes start an extra avatar solely to read the
    # instructions. I don't want these avatars appearing on the
    # dashboard. When forking a new kata you can enter as one
    # animal to sanity check it is ok (but not press [test])
    !lights.empty?
  end

  def tags
    increments.map { |h| Tag.new(@externals, self, h) }
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

  private # = = = = = = = = =

  def increments
    storer.avatar_increments(kata.id, name)
  end

  def storer
    @externals.storer
  end

  def runner
    @externals.runner
  end

end
