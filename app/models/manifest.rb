
class Manifest

  def initialize(manifest)
    @manifest = manifest
  end

  def group_id
    # nil if individual practice-session
    manifest_entry # eg '8bvlJk'
  end

  def group_index
    # nil if individual practice-session
    manifest_entry # eg 45 (==salmon)
  end

  # required

  def id
    manifest_entry # eg '260za8'
  end

  def display_name
    manifest_entry # eg 'Python, py.test'
  end

  def image_name
    manifest_entry # eg 'cyberdojofoundation/java_junit'
  end

  def runner_choice
    manifest_entry # eg 'stateless'
  end

  def created
    Time.mktime(*manifest_entry) # eg [2018,10,14, 9,50,23]
  end

  def filename_extension
    if manifest_entry.is_a?(Array)
      manifest_entry     # eg  [ ".c", ".h" ]
    else
      [ manifest_entry ] # eg ".py" -> [ ".py" ]
    end
  end

  # optional

  def exercise
    manifest_entry # present in language+testFramework kata
  end              # not present in custom kata

  def highlight_filenames
    manifest_entry || []
  end

  def hidden_filenames
    manifest_entry || []
  end

  def tab_size
    manifest_entry || 4
  end

  def max_seconds
    manifest_entry || 10
  end

  def progress_regexs
    # [] is not a valid progress_regex.
    # It needs two regexs.
    # This affects zipper.zip_tag()
    manifest_entry || []
  end

  private

  def manifest_entry
    @manifest[name_of(caller)]
  end

  def name_of(caller)
    # eg caller[0] == "manifest.rb:58:in `tab_size'"
    /`(?<name>[^']*)/ =~ caller[0] && name
  end

end
