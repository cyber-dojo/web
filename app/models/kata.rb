
class Kata

  def initialize(katas, id)
    # Does *not* validate. All access to kata object must come through dojo.katas[id]
    @katas = katas
    @id = id
  end

  # modifiers

  def start_avatar(avatar_names = Avatars.names.shuffle)
    katas.kata_start_avatar(self, avatar_names)
  end

  # queries

  attr_reader :katas, :id

  def parent
    katas
  end

  def avatars
    Avatars.new(self)
  end

  def active?
    avatars.active.count > 0
  end

  def age(now = Time.now.to_a[0..5].reverse)
    # Time.now.to_a     [18, 7, 11, 22, 5, 2016, 0, 143, true, "BST"]
    # [0..5]            [18, 7, 11, 22, 5, 2016]
    # reverse           [2016, 5, 22, 11, 7, 18] = 2016 May 22nd, 11:07:18
    return 0 unless active?
    return (Time.mktime(*now) - earliest_light).to_i
  end

  def created
    Time.mktime(*manifest_property)
  end

  def visible_files
    manifest_property
  end

  def unit_test_framework
    manifest_property
  end

  def tab_size
    manifest_property
  end

  def image_name
    # Not stored in the kata's manifest until July 2016.
    # Meant that display-name changes made it impossible to
    # fork from a traffic-light since you could not get back to
    # the kata's language object to get its image_name.
    # For old kata's, attempt to retrieve the image_name from the
    # language object, which may fail if...
    #   o) the language has been renamed
    #   o) language was from a different start-points volume
    manifest_property || language.image_name
  end

  def display_name
    # Could do...
    #    manifest['language'].split('-').join(', ')
    # assumes
    #    o) there is only one hyphen
    #    o) there is a space after the comma in display_name
    # Example
    #    manifest['language'] = 'Java-JUnit'
    #    --> split('-').join(', ')
    #    --> 'Java, JUnit'
    language.display_name
  end

  def filename_extension
    language.filename_extension
  end

  def progress_regexs
    language.progress_regexs
  end

  def highlight_filenames
    language.highlight_filenames
  end

  def lowlight_filenames
    language.lowlight_filenames
  end

  def colour(output)
    OutputColour.of(unit_test_framework, output)
  end

  # TODO: make private?
  def manifest
    @manifest ||= katas.kata_manifest(self)
  end

  private

  include ExternalParentChainer
  include ManifestProperty

  def earliest_light
    Time.mktime(*avatars.active.map { |avatar| avatar.lights[0].time }.sort[0])
  end

  def language
    # Each avatar does _not_ choose their own language+test.
    # The language+test is chosen for the _dojo_.
    # cyber-dojo is a team-based Interactive Dojo Environment,
    # not an Individual Development Environment
    name = manifest['language']
    # TODO: This is a hack. Revisit.
    #  Its a manifested language (+test) for the regular case of
    #    starting from an empty instruction file.
    #  Its a manifested custom exercise (like James uses) - the new case
    languages[name] || custom[name]
  end

end
