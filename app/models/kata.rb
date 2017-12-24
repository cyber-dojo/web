
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

  def exists?
    storer.kata_exists?(id)
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
    manifest_property # required
  end

  def major_name
    display_name.split(',',2)[0].strip
  end

  def minor_name
    display_name.split(',',2)[1].strip
  end

  def exercise
    manifest_property # required in language kata
  end                 # not required in custom kata

  # - - - - - - - - - - - - -
  # file-knave

  def filename_extension
    manifest_property # defaults to ''
  end

  def highlight_filenames
    manifest_property # defaults to []
  end

  def lowlight_filenames
    manifest_property  # has a default
  end

  def tab_size
    manifest_property # defaults to 4
  end

  # - - - - - - - - - - - - -
  # source

  def visible_files
    manifest_property # required
  end

  # - - - - - - - - - - - - -
  # runner

  def image_name
    manifest_property # required
  end

  def max_seconds
    # Some tests use StorerFake which does not
    # mimic StorerService defaults yet...
    manifest_property || 10 # defaults to 10
  end

  def runner_choice
    manifest_property # required
  end

  # - - - - - - - - - - - - -
  # dashboard

  def created
    Time.mktime(*manifest_property)
  end

  def progress_regexs
    manifest_property # has a default
  end

  private

  include NameOfCaller

  def manifest_property
    manifest[name_of(caller)]
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
