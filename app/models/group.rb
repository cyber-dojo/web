
class Group

  def initialize(externals, id)
    @externals = externals
    @id = id
  end

  def id
    @id
  end

  def exists?
    @exists ||= grouper.id?(@id)
  end

  # - - - - - - - - - - - - -

  def katas
    joined.map{ |_    ,sid| Kata.new(@externals, sid) }
  end

  def avatars
    joined.map{ |index,sid| Avatar.new(@externals, sid, index) }
  end

  # - - - - - - - - - - - - -

  def age
    ages = katas.select(&:active?).map{ |kata| kata.age }
    ages == [] ? 0 : ages.sort[-1]
  end

  def progress_regexs # optional
    # TODO: [] is not a valid progress_regex.
    # It needs two regexs.
    # This affects zipper.zip_tag()
    manifest_property || []
  end

  def created # required
    Time.mktime(*manifest_property)
  end

  private

  def joined
    @joined ||= grouper.joined(id)
  end

  def manifest_property
    manifest[name_of(caller)]
  end

  def manifest
    @manifest ||= grouper.manifest(id)
  end

  def name_of(caller)
    # eg caller[0] == "group.rb:28:in `created'"
    /`(?<name>[^']*)/ =~ caller[0] && name
  end

  def grouper
    @externals.grouper
  end

end
