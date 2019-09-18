# frozen_string_literal: true

class Manifest

  def initialize(manifest)
    @manifest = manifest
  end

  def self.required(*names)
    names.each do |name|
      define_method name do
        @manifest[name.to_s]
      end
    end
  end

  # - - - - - - - - - -

  def self.optional(names)
    names.each do |name,default|
      define_method name do
        @manifest[name.to_s] || default
      end
    end
  end

  # - - - - - - - - - -

  required :group_id,           # eg '8bvlJk',    nil if !group-session
           :group_index,        # eg 45 (salmon), nil if !group-session
           :created,            # eg [2018,10,14, 9,50,23]
           :display_name,       # eg 'Java, JUnit'
           :filename_extension, # eg [ '.java' ]
           :id,                 # eg '260za8'
           :image_name          # eg 'cyberdojofoundation/java_junit'

  # - - - - - - - - - -

  optional({
               exercise:'',
    highlight_filenames:[],
       hidden_filenames:[],
               tab_size:4,
            max_seconds:10,
        progress_regexs:[]
  })

  # - - - - - - - - - -

  def to_json
    {
      'display_name' => display_name,
      'filename_extension' => filename_extension,
      'image_name' => image_name,
      'exercise' => exercise,
      'highlight_filenames' => highlight_filenames,
      'hidden_filenames' => hidden_filenames,
      'tab_size' => tab_size,
      'max_seconds' => max_seconds,
      'progress_regexs' => progress_regexs
    }
  end

end
