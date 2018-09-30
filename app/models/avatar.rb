
class Avatar

  def initialize(externals, id, name)
    # Does *not* validate.
    @externals = externals
    @id = id
    @name = name
  end

  attr_reader :id, :name

  def kata
    Kata.new(@externals, id)
  end

  def active?
    kata.active?
  end

  # modifiers

  #TODO: rename to run_tests()
  def test(delta, files, max_seconds, image_name = kata.image_name)
    args = []
    args << image_name        # eg 'cyberdojofoundation/gcc_assert'
    args << id                # eg 'FE8A79A264'
    args << max_seconds       # eg 10
    args << delta
    args << files
    runner.run(*args)
  end

  #TODO: rename to ran_tests()
  def tested(files, at, stdout, stderr, colour)
    args += [id, files, at, stdout, stderr, colour]
    increments = singler.ran_tests(*args)
    increments.map { |h| Tag.new(@externals, self, h) }
  end

  # queries

  def tags
    increments.map { |h| Tag.new(@externals, id, h) }
  end

  def lights
    tags.select(&:light?)
  end

  def visible_filenames
    visible_files.keys
  end

  def visible_files
    singler.visible_files(id)
  end

  private # = = = = = = = = =

  def increments
    singler.increments(id)
  end

  def singler
    @externals.singler
  end

  def runner
    @externals.runner
  end

end
