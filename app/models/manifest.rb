
class Manifest

  def initialize(externals, id)
    @externals = externals
    @id = id
  end

  def id
    @id
  end

  def group
    manifest_entry
  end

  def display_name # required
    manifest_entry # eg 'Python, py.test'
  end

  def exercise
    manifest_entry # present in language+testFramework kata
  end              # not present in custom kata

  def filename_extension # required
    if manifest_entry.is_a?(Array)
      manifest_entry     # eg  [ ".c", ".h" ]
    else
      [ manifest_entry ] # eg ".py" -> [ ".py" ]
    end
  end

  def highlight_filenames # optional
    manifest_entry || []
  end

  def hidden_filenames # optional
    manifest_entry || []
  end

  def tab_size # optional
    manifest_entry || 4
  end

  def image_name # required
    manifest_entry
  end

  def max_seconds # optional
    manifest_entry || 10
  end

  def runner_choice # required
    manifest_entry
  end

  def created # required
    Time.mktime(*manifest_entry)
  end

  def progress_regexs # optional
    # [] is not a valid progress_regex.
    # It needs two regexs.
    # This affects zipper.zip_tag()
    manifest_entry || []
  end

  private

  def manifest_entry
    manifest[name_of(caller)]
  end

  def manifest
    @manifest ||= singler.manifest(id)
  end

  def name_of(caller)
    # eg caller[0] == "manifest.rb:34:in `tab_size'"
    /`(?<name>[^']*)/ =~ caller[0] && name
  end

  def singler
    @externals.singler
  end

end