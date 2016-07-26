
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

  def exercise
    manifest_property
  end

  def language
    manifest_property
  end

  def image_name
    full_manifest_property
  end

  def display_name
    full_manifest_property
  end

  def filename_extension
    full_manifest_property
  end

  def progress_regexs
    full_manifest_property
  end

  def highlight_filenames
    full_manifest_property
  end

  def lowlight_filenames
    full_manifest_property
  end

  def red_amber_green(output)
    if Regexp.new('Unable to complete the test').match(output)
      return 'timed_out'
    end
    # before or after start-points re-architecture?
    src = manifest['red_amber_green']
    if output.nil?
      return src
    end
    if src.nil? # before
      OutputColour.of(unit_test_framework, output)
    else # after
      colour = eval(src.join("\n"))
      colour.call(output).to_s
    end
  end

  private

  include ExternalParentChainer
  include ManifestProperty

  def full_manifest_property
    # Not stored in the kata's manifest until the
    # start-points volume re-architecture (July 2016)
    property_name = name_of(caller)
    manifest[property_name] || start_point.send(property_name)
  end

  def start_point
    # A kata's manifest should store everything it needs so it
    # never has to go back to its originating language+test manifest.
    # e,g, the image_name and a red_amber_green parse lambda.
    # katas created after the start-point volume re-architecture do that :-)
    # katas created before the start-point volume re-architecture don't :-(
    # So for katas before I attempt to navigate back to the originating
    # language+test. Note that this affects forking too.
    name = manifest['language']
    # There are now two start-points origins...
    languages[name] || custom[name]
  end

  def manifest
    @manifest ||= katas.kata_manifest(self)
  end

  def earliest_light
    Time.mktime(*avatars.active.map { |avatar| avatar.lights[0].time }.sort[0])
  end

end

# Each avatar does _not_ choose their own language+test.
# The language+test is chosen for the _kata_.
# cyber-dojo is a team-based Interactive Dojo Environment,
# not an Individual Development Environment
