
class Kata

  def initialize(externals, id)
    # Does *not* validate.
    @externals = externals
    @id = id
  end

  # - - - - - - - - - - - - -

  def avatar_start(avatar_names = Avatars.names.shuffle)
    name = storer.avatar_start(id, avatar_names)
    unless name.nil?
      begin
        runner.avatar_new(image_name, id, name, visible_files)
      rescue StandardError => error
        # o) resuming old !stateless kata whose state has been collected?
        # o) runner_choice switched from stateless?
        no_kata = (error.message == 'RunnerService:avatar_new:kata_id:!exists')
        raise error unless no_kata
        runner.kata_new(image_name, id)
        runner.avatar_new(image_name, id, name, visible_files)
      end
    end
    name.nil? ? nil : Avatar.new(externals, self, name)
  end

  # - - - - - - - - - - - - -
  # queries

  def exists?
    storer.kata_exists?(id)
  end

  def avatars
    Avatars.new(externals, self)
  end

  def active?
    avatars.active.count > 0
  end

  def id
    @id
  end

  # - - - - - - - - - - - - -
  # info-bar

  def display_name  # required
    # eg 'Python, py.test'
    manifest_property
  end

  def exercise
    manifest_property # present in language+testFramework kata
  end                 # not present in custom kata

  # - - - - - - - - - - - - -
  # filenames

  def filename_extension # required
    if manifest_property.is_a? Array
      manifest_property # eg  [ ".c", ".h" ]
    else
      [ manifest_property ] # eg ".py"
    end
  end

  def highlight_filenames # optional
    manifest_property || []
  end

  # - - - - - - - - - - - - -
  # source

  def tab_size # optional
    manifest_property || 4
  end

  def visible_files # required
    manifest_property
  end

  # - - - - - - - - - - - - -
  # runner

  def image_name # required
    manifest_property
  end

  def max_seconds # optional
    manifest_property || 10
  end

  def runner_choice # required
    manifest_property
  end

  # - - - - - - - - - - - - -
  # dashboard

  def created # required
    Time.mktime(*manifest_property)
  end

  def progress_regexs # optional
    # [] is not a valid progress_regex.
    # It needs two regexs.
    # This affects zipper.zip_tag()
    manifest_property || []
  end

  def age
    first_times = []
    last_times = []
    # using storer.kata_increments() as BatchMethod
    storer.kata_increments(id).each do |name,increments|
      avatar = Avatar.new(externals, self, name)
      tags = increments.map { |h| Tag.new(externals, avatar, h) }
      lights = tags.select(&:light?)
      if lights != []
        first_times << lights[0].time
        last_times  << lights[-1].time
      end
    end
    first_times == [] ? 0 : (last_times.sort[-1] - first_times.sort[0]).to_i
  end

  private # = = = = = = = = = =

  def manifest_property
    manifest[name_of(caller)]
  end

  # - - - - - - - - - - - - -

  def manifest
    @manifest ||= storer.kata_manifest(id)
  end

  # - - - - - - - - - - - - -

  def name_of(caller)
    # eg caller[0] == "kata.rb:1077:in `tab_size'"
    /`(?<name>[^']*)/ =~ caller[0] && name
  end

  # - - - - - - - - - - - - -

  attr_reader :externals

  def runner
    externals.runner
  end

  def storer
    externals.storer
  end

end

# Each avatar does _not_ choose their own language+test.
# The language+test is chosen for the _kata_.
# cyber-dojo is a team-based Interactive Dojo Environment,
# not an Individual Development Environment
