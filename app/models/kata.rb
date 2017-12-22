
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

  def parent
    @katas
  end

  def avatars
    Avatars.new(self)
  end

  def active?
    avatars.active.count > 0
  end

  # - - - - - - - - - - - - -
  # properties
  # - - - - - - - - - - - - -

  def id
    @id
  end

  # - - - - - - - - - - - - -
  # info-bar

  def display_name
    manifest_property
  end

  def language
    manifest_property
  end

  def exercise
    manifest_property
  end

  # - - - - - - - - - - - - -
  # file-knave

  def filename_extension
    manifest_property
  end

  def highlight_filenames
    manifest_property
  end

  def lowlight_filenames
    manifest_property
  end

  def tab_size
    manifest_property
  end

  def visible_files
    manifest_property
  end

  # - - - - - - - - - - - - -
  # runner

  def image_name
    manifest_property
  end

  def max_seconds
    manifest_property
  end

  def runner_choice
    manifest_property
  end

  # - - - - - - - - - - - - -
  # dashboard

  def created
    Time.mktime(*manifest_property)
  end

  def progress_regexs
    manifest_property
  end

  private

  include NameOfCaller

  def manifest_property
    property_name = name_of(caller)
    manifest[property_name]
  end

  def manifest
    @manifest ||= storer.kata_manifest(id)
  end

  include NearestAncestors

  def runner
    nearest_ancestors(:runner)
  end

  def storer
    nearest_ancestors(:storer)
  end

end

# Each avatar does _not_ choose their own language+test.
# The language+test is chosen for the _kata_.
# cyber-dojo is a team-based Interactive Dojo Environment,
# not an Individual Development Environment
