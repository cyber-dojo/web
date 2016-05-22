
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

  def language
    # TODO: This is a hack. Revisit.
    #  The language is now doing double duty.
    #  Its a manifested language (+test) for the regular case of
    #    starting from an empty instruction file.
    #  Its a manifested exercise (like James uses) - the new case
    languages[language_name] || exercises[language_name]
  end

  def instructions
    # careful not to recurse here
    parent.instructions[instructions_name]
  end

  def language_name
    # used in forker_controller
    manifest['language']
  end

  def instructions_name
    # used in forker_controller
    manifest['exercise']
  end

  private

  include ExternalParentChainer
  include ManifestProperty

  def manifest
    @manifest ||= katas.kata_manifest(self)
  end

  def earliest_light
    Time.mktime(*avatars.active.map { |avatar| avatar.lights[0].time }.sort[0])
  end

end
