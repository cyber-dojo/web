
class Manifest

  def initialize(manifest)
    @manifest = manifest
  end

  # - - - - - - - - - - - - - - - - - - - - - -

  def self.required(*names)
    names.each do |name|
      define_method name do
        @manifest[name.to_s]
      end
    end
  end

  def self.optional(fields)
    fields.each do |name,default|
      define_method name do
        @manifest[name.to_s] || default
      end
    end
  end

  # - - - - - - - - - - - - - - - - - - - - - -

  required :group_id,    # eg '8bvlJk',    nil if !group-practice-session
           :group_index, # eg 45 (salmon), nil if !group-practice-session
           :created,            # eg [2018,10,14, 9,50,23]
           :display_name,       # eg 'Java, JUnit'
           :filename_extension, # eg [ '.java' ]
           :id,                 # eg '260za8'
           :image_name,         # eg 'cyberdojofoundation/java_junit'
           :runner_choice       # eg 'stateless'

  optional({
               exercise:'',
    highlight_filenames:[],
       hidden_filenames:[],
               tab_size:4,
            max_seconds:10,
        progress_regexs:[]
  })

end
