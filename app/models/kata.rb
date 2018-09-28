require_relative '../../lib/phonetic_alphabet'

class Kata

  def initialize(externals, id)
    # Does *not* validate.
    @externals = externals
    @id = id
  end

  # - - - - - - - - - - - - -

  def group
    gid = manifest_property
    if gid.nil?
      nil
    else
      groups[gid]
    end
  end

  # - - - - - - - - - - - - -

  def visible_files
    singler.visible_files(id)
  end

  def tags
    singler.increments(id).map { |h| Tag.new(@externals, id, h) }
  end

  def lights
    tags.select(&:light?)
  end

  # - - - - - - - - - - - - -
  # identifier

  def exists?
    singler.id?(id)
  end

  def id
    @id
  end

  def short_id
    id[0..5]
  end

  def phonetic_short_id
    Phonetic.spelling(short_id).join('-')
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
  # filenames/tabs

  def filename_extension # required
    if manifest_property.is_a?(Array)
      manifest_property # eg  [ ".c", ".h" ]
    else
      [ manifest_property ] # eg ".py" -> [ ".py" ]
    end
  end

  def highlight_filenames # optional
    manifest_property || []
  end

  def hidden_filenames # optional
    manifest_property || []
  end

  def tab_size # optional
    manifest_property || 4
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

  private # = = = = = = = = = =

  def manifest_property
    manifest[name_of(caller)]
  end

  # - - - - - - - - - - - - -

  def manifest
    @manifest ||= singler.manifest(id)
  end

  # - - - - - - - - - - - - -

  def name_of(caller)
    # eg caller[0] == "kata.rb:1077:in `tab_size'"
    /`(?<name>[^']*)/ =~ caller[0] && name
  end

  # - - - - - - - - - - - - -

  def groups
    Groups.new(externals)
  end

  attr_reader :externals

  def singler
    externals.singler
  end

=begin
  def active?
    avatars.active.count > 0
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
=end

end

# Each avatar does _not_ choose their own language+test.
# The language+test is chosen for the _kata_.
# cyber-dojo is a team-based Interactive Dojo Environment,
# not an Individual Development Environment
