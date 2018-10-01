
class Group

  def initialize(externals, id)
    # Does *not* validate.
    @externals = externals
    @id = id
  end

  # - - - - - - - - - - - - -

  def id
    @id
  end

  def exists?
    grouper.id?(id)
  end

  def age
    ages = avatars.active.map{ |avatar| avatar.kata.age }
    ages == [] ? 0 : ages.sort[-1]
  end

  def avatars
    Avatars.new(@externals, id)
  end

  # - - - - - - - - - - - - -

  def created # required
    Time.mktime(*manifest_property)
  end

  def progress_regexs # optional
    # [] is not a valid progress_regex.
    # It needs two regexs.
    # This affects zipper.zip_tag()
    manifest_property || []
  end

  private

  def manifest_property
    manifest[name_of(caller)]
  end

  # - - - - - - - - - - - - -

  def manifest
    @manifest ||= grouper.manifest(id)
  end

  # - - - - - - - - - - - - -

  def name_of(caller)
    # eg caller[0] == "group.rb:28:in `created'"
    /`(?<name>[^']*)/ =~ caller[0] && name
  end

  def grouper
    @externals.grouper
  end

end
