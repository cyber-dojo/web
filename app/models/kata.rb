
class Kata

  def initialize(katas, id)
    # Does *not* validate.
    # All access to kata object must come through katas[id]
    @katas = katas
    @id = id
  end

  # modifiers

  def start_avatar(avatar_names = Avatars.names.shuffle)
    name = storer.start_avatar(id, avatar_names)
    unless name.nil?
      begin
        runner.avatar_new(image_name, id, name, visible_files)
      rescue StandardError => error
        # Old kata could be being resumed
        # Runner implementation could have switched
        no_kata = (error.message == 'RunnerService:avatar_new:kata_id:!exists')
        raise error unless no_kata
        runner.kata_new(image_name, id)
        runner.avatar_new(image_name, id, name, visible_files)
      end
    end
    name.nil? ? nil : Avatar.new(self, name)
  end

  # queries

  attr_reader :id

  def parent
    @katas
  end

  def avatars
    Avatars.new(self)
  end

  def active?
    avatars.active.count > 0
  end

  def created
    Time.mktime(*manifest_property)
  end

  # - - - - - - - - - - - - -

  def visible_files
    manifest_property
  end

  def unit_test_framework
    # not stored in manifest after start-point
    # volume re-architecture
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

  # - - - - - - - - - - - - -

  def stateful
    full_manifest_property
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

  private

  include ManifestProperty

  def full_manifest_property
    # A kata's manifest should store everything
    # it needs so it never has to go back to its
    # originating language+test manifest (decoupling).
    # Katas created after the start-point volume
    # re-architecture do that :-) Katas created before
    # the start-point volume re-architecture don't :-(
    # For katas before I attempt to navigate back to
    # the originating language+test.
    property_name = name_of(caller)
    manifest[property_name] || start_point.send(property_name)
  end

  def start_point
    name = language
    languages[name] || custom[name]
  end

  def manifest
    @manifest ||= storer.kata_manifest(id)
  end

  include NearestAncestors
  def languages; nearest_ancestors(:languages); end
  def custom   ; nearest_ancestors(:custom   ); end

  def runner; nearest_ancestors(:runner); end
  def storer; nearest_ancestors(:storer); end

end

# Each avatar does _not_ choose their own language+test.
# The language+test is chosen for the _kata_.
# cyber-dojo is a team-based Interactive Dojo Environment,
# not an Individual Development Environment
