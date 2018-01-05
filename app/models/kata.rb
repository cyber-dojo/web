
class Kata

  def initialize(externals, katas, id)
    # Does *not* validate.
    @externals = externals
    @katas = katas
    @id = id
  end

  # - - - - - - - - - - - - -

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
    name.nil? ? nil : Avatar.new(@externals, self, name)
  end

  # - - - - - - - - - - - - -

  def fork(visible_files)
    forked = manifest.clone
    forked.delete('id')
    forked.delete('created')
    forked['visible_files'] = visible_files
    @katas.create_kata(forked)
    forked
  end

  # - - - - - - - - - - - - -
  # queries

  def exists?
    storer.kata_exists?(id)
  end

  def avatars
    Avatars.new(@externals, self)
  end

  def active?
    avatars.active.count > 0
  end

  def id
    @id
  end

  # - - - - - - - - - - - - -
  # info-bar

  def display_name
    # eg 'Python, py.test'
    manifest_property # required
  end

  def major_name
    # eg 'Python
    commad(display_name)[0]
  end

  def minor_name
    # eg 'py.test'
    commad(display_name)[1]
  end

  def exercise
    manifest_property # required in language kata
  end                 # not required in custom kata

  # - - - - - - - - - - - - -
  # filenames

  def filename_extension
    manifest_property || ''
  end

  def highlight_filenames
    manifest_property || []
  end

  def lowlight_filenames
    default_lowlight_filenames =
      if highlight_filenames.empty?
        %w( cyber-dojo.sh makefile Makefile unity.license.txt )
      else
        visible_files.keys - highlight_filenames
      end
    manifest_property || default_lowlight_filenames
  end

  # - - - - - - - - - - - - -
  # source

  def tab_size
    manifest_property || 4
  end

  def visible_files
    manifest_property # required
  end

  # - - - - - - - - - - - - -
  # runner

  def image_name
    manifest_property # required
  end

  def max_seconds
    manifest_property || 10
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
    # [] is not a valid progress_regex.
    # It needs two regexs.
    # This affects zipper.zip_tag()
    manifest_property || []
  end

  private # = = = = = = = = = =

  def manifest_property
    manifest[name_of(caller)]
  end

  def manifest
    @manifest ||= updated(storer.kata_manifest(id))
  end

  def name_of(caller)
    # eg caller[0] == "kata.rb:1077:in `tab_size'"
    /`(?<name>[^']*)/ =~ caller[0] && name
  end

  # - - - - - - - - - - - - -

  def updated(manifest)
    if manifest['unit_test_framework']
      # manifest change #1
      # manifest became self-contained rather than
      # having to retrieve information from start-point
      old_name = manifest['language']
      xlated = starter.manifest(old_name)
      xlated['id'] = manifest['id']
      xlated['created'] = manifest['created']
      # this happened before custom start-points
      xlated['exercise'] = manifest['exercise']
      return xlated
    end
    if manifest['runner_choice'].nil?
      # manifest change #2
      # added runner_choice required parameter
      old_name = commad(manifest['display_name']).join('-')
      xlated = starter.manifest(old_name)
      manifest['runner_choice'] = xlated['runner_choice']
      return manifest
    end
    manifest
  end

  # - - - - - - - - - - - - -

  def commad(name)
    name.split(',',2).map(&:strip)
  end

  def runner
    @externals.runner
  end

  def starter
    @externals.starter
  end

  def storer
    @externals.storer
  end

end

# Each avatar does _not_ choose their own language+test.
# The language+test is chosen for the _kata_.
# cyber-dojo is a team-based Interactive Dojo Environment,
# not an Individual Development Environment
