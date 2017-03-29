
class StartPoint

  def initialize(start_points, path, display_name = nil, image_name = nil)
    @start_points = start_points
    @path = path
    @display_name = display_name
    @image_name = image_name
  end

  attr_reader :path

  def parent
    @start_points
  end

  def create_kata_manifest(id = unique_id, now = time_now)
    manifest = {
                       'id' => id,
                  'created' => now,
               'image_name' => image_name,
             'display_name' => display_name,
       'filename_extension' => filename_extension,
          'progress_regexs' => progress_regexs,
      'highlight_filenames' => highlight_filenames,
       'lowlight_filenames' => lowlight_filenames,
                 'language' => name,
                 'tab_size' => tab_size
    }
    manifest['visible_files'] = visible_files
    manifest['visible_files']['output'] = ''
    manifest
  end

  # required manifest properties

  def display_name
    # See comments below
    @display_name ||= manifest_property
  end

  def image_name
    # See comments below
    @image_name ||= manifest_property
  end

  def visible_filenames
    manifest_property
  end

  def visible_files
    Hash[visible_filenames.collect { |filename|
      [filename, disk[path].read(filename)]
    }]
  end

  # optional manifest properties

  def filename_extension
    manifest_property || ''
  end

  def highlight_filenames
    manifest_property || []
  end

  def progress_regexs
    # Issue: [] is not a valid progress_regex. It needs two regexs.
    # This affects zipper.zip_tag()
    manifest_property || []
  end

  def tab_size
    manifest_property || 4
  end

  # not manifest properties

  def lowlight_filenames
    # See comments below
    if highlight_filenames.empty?
      ['cyber-dojo.sh', 'makefile', 'Makefile', 'unity.license.txt']
    else
      visible_filenames - highlight_filenames
    end
  end

  def name
    # as stored in the kata's manifest
    display_name.split(',').map(&:strip).join('-')
  end

  private

  include ManifestProperty
  include NearestAncestors
  include TimeNow
  include UniqueId

  def manifest
    @manifest ||= disk[path].read_json(manifest_filename)
  rescue StandardError => e
    message = "disk[path].read_json(#{manifest_filename}) exception" + "\n" +
      'start-point: ' + path + "\n" +
      '    message: ' + e.message
    fail message
  end

  def manifest_filename
    'manifest.json'
  end

  def disk; nearest_ancestors(:disk); end

end

# - - - - - - - - - - - - - - - - - - - -
# display_name
# - - - - - - - - - - - - - - - - - - - -
# ||= caching is to optimize the setup page
# - - - - - - - - - - - - - - - - - - - -


# - - - - - - - - - - - - - - - - - - - -
# image_name
# - - - - - - - - - - - - - - - - - - - -
# ||= caching is to optimize the setup page
# If you upgrade a start-point, eg to a newer
# compiler version, or a newer test-framework,
# do *not* change the image_name.
# Keeping any version numbers out of the image_name
# and not changing it ensures forking always works.
# - - - - - - - - - - - - - - - - - - - -


# - - - - - - - - - - - - - - - - - - - -
# lowlight_filenames
# - - - - - - - - - - - - - - - - - - - -
# Caters for two uses
# 1. carefully constructed (custom) set of start
#    files (like James Grenning uses) with explicitly
#    set highlight_filenames entry in manifest
# 2. default start-points files viz,
#    no highlight_filenames entry in manifest
# - - - - - - - - - - - - - - - - - - - -
