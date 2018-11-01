
class Manifest

  def initialize(manifest)
    @manifest = manifest
  end

  def self.required(*names)
    names.each do |name|
      define_method name, &lambda {
        @manifest[name.to_s]
      }
    end
  end

  required :group_id,    # eg '8bvlJk',    nil if !group-practice-session
           :group_index, # eg 45 (salmon), nil if !group-practice-session
           :created,            # eg [2018,10,14, 9,50,23]
           :display_name,       # eg 'Python, py.test'
           :filename_extension, # eg [ ".py" ]
           :id,                 # eg '260za8'
           :image_name,         # eg 'cyberdojofoundation/java_junit'
           :runner_choice       # eg 'stateless'

  # optional

  def exercise
    manifest_entry || '' # present in language+testFramework kata
  end                    # not present in custom kata

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
