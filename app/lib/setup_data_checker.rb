
require 'json'

class SetupDataChecker

  def initialize(path)
    @path = path.chomp('/')
    @manifests = {}
    @errors = {}
  end

  attr_reader :manifests # [manifest-filename] => json-manifest-object
  attr_reader :errors    # [manifest-filename] => [ error, ... ]

  # - - - - - - - - - - - - - - - - - - - -

  def check
    # check setup.json in root but do not add to manifests[]
    manifest = json_manifest(setup_filename)
    check_setup_json_meets_its_spec(manifest) unless manifest.nil? #TODO: move nil? check inside method
    # json-parse all manifest.json files and add to manifests[]
    Dir.glob("#{@path}/**/manifest.json").each do |filename|
      manifest = json_manifest(filename)
      @manifests[filename] = manifest unless manifest.nil?
    end
    # check manifests
    # TODO: instructions-checks are different to languages/exercises checks
    check_all_manifests_have_a_unique_display_name
    @manifests.each do |filename, manifest|
      check_all_required_keys_exist(filename, manifest)
      check_all_files_present_in_visible_filenames(filename, manifest)
      check_no_unknown_keys_exist(filename, manifest)
      check_all_visible_files_exist(filename, manifest)
      check_no_duplicate_visible_files(filename, manifest)
      check_display_name_is_valid(filename, manifest)
      check_image_name_is_not_empty(filename, manifest)
      check_progress_regexs_is_valid(filename, manifest)
    end
    errors
  end

  private

  # TODO: check there is at least one sub-dir with a manifest.json file
  # TODO: check at least one manifest has auto_pull:true ?

  def check_setup_json_meets_its_spec(manifest)
    type = manifest['type']
    if type.nil?
      @errors[setup_filename] << 'no type: entry'
    elsif ! ['languages','exercises','instructions'].include? type
      @errors[setup_filename] << 'bad type: entry'
    end
  end

  # - - - - - - - - - - - - - - - - - - - -

  def check_all_manifests_have_a_unique_display_name
    display_names = {}
    @manifests.each do |filename, manifest|
      display_name = manifest['display_name']
      display_names[display_name] ||= []
      display_names[display_name] << filename
    end
    display_names.each do |display_name, filenames|
      if filenames.size > 1
        filenames.each do |filename|
          @errors[filename] << "duplicate display_name:'#{display_name}'"
        end
      end
    end
  end

  # - - - - - - - - - - - - - - - - - - - -

  def check_all_required_keys_exist(manifest_filename, manifest)
    required_keys = %w( display_name
                        image_name
                        unit_test_framework
                        visible_filenames
                      )
    required_keys.each do |key|
      unless manifest.keys.include? key
        @errors[manifest_filename] << "missing required key '#{key}'"
      end
    end
  end

  # - - - - - - - - - - - - - - - - - - - -

  def check_all_files_present_in_visible_filenames(manifest_filename, manifest)
    visible_filenames = manifest['visible_filenames']
    return if visible_filenames.nil? # different check
    dir = File.dirname(manifest_filename)
    filenames = Dir.entries(dir).reject { |entry| File.directory?(entry) }
    filenames -= [ 'manifest.json' ]
    filenames.each do |filename|
      unless visible_filenames.include? filename
        @errors[manifest_filename] << "#{filename} not present in visible_filenames:"
      end
    end
  end

  # - - - - - - - - - - - - - - - - - - - -

  def check_no_unknown_keys_exist(manifest_filename, manifest)
    known_keys = %w( display_name
                     filename_extension
                     highlight_filenames
                     image_name
                     progress_regexs
                     tab_size
                     unit_test_framework
                     visible_filenames
                   )
    manifest.keys.each do |key|
      unless known_keys.include? key
        @errors[manifest_filename] << "unknown key '#{key}'"
      end
    end
  end

  # - - - - - - - - - - - - - - - - - - - -

  def check_all_visible_files_exist(manifest_filename, manifest)
    visible_filenames = manifest['visible_filenames']
    return if visible_filenames.nil? # required-key different check
    dir = File.dirname(manifest_filename)
    visible_filenames.each do |filename|
      unless File.exists?(dir + '/' + filename)
        @errors[manifest_filename] << "missing visible_filename '#{filename}'"
      end
    end
  end

  # - - - - - - - - - - - - - - - - - - - -

  def check_no_duplicate_visible_files(manifest_filename, manifest)
    visible_filenames = manifest['visible_filenames']
    return if visible_filenames.nil? # required-key different check
    visible_filenames.uniq.each do |filename|
      unless visible_filenames.count(filename) == 1
        @errors[manifest_filename] << "duplicate visible_filename '#{filename}'"
      end
    end
  end

  # - - - - - - - - - - - - - - - - - - - -

  def check_display_name_is_valid(manifest_filename, manifest)
    display_name = manifest['display_name']
    return if display_name.nil? # required-key different check
    parts = display_name.split(',').select { |part| part.strip != '' }
    unless parts.length == 2
      @errors[manifest_filename] << "display_name not in 'A,B' format"
    end
  end

  # - - - - - - - - - - - - - - - - - - - -

  def check_image_name_is_not_empty(manifest_filename, manifest)
    image_name = manifest['image_name']
    return if image_name.nil? # required-key different check
    if image_name == ''
      @errors[manifest_filename] << 'image_name is empty'
    end
  end

  # - - - - - - - - - - - - - - - - - - - -

  def check_progress_regexs_is_valid(manifest_filename, manifest)
    regexs = manifest['progress_regexs']
    return if regexs.nil?  # optional-key
    if regexs.class.name != 'Array'
      @errors[manifest_filename] << 'progress_regexs: must be an Array'
      return
    end
    if regexs.length != 2
      @errors[manifest_filename] << 'progress_regexs: must contain 2 items'
      return
    end
    if regexs.any? { |item| item.class.name != 'String' }
      @errors[manifest_filename] << 'progress_regexs: must contain 2 strings'
      return
    end
    regexs.each do |s|
      begin
        Regexp.new(s)
      rescue
        @errors[manifest_filename] << "progress_regexs: cannot create regex from #{s}"
      end
    end

  end

  # - - - - - - - - - - - - - - - - - - - -

  def setup_filename
    @path + '/setup.json'
  end

  # - - - - - - - - - - - - - - - - - - - -

  def json_manifest(filename)
    @errors[filename] = []
    unless File.exists?(filename)
      @errors[filename] << 'missing'
      return nil
    end
    begin
      content = IO.read(filename)
      return JSON.parse(content)
    rescue JSON::ParserError
      @errors[filename] << 'bad JSON'
    end
    return nil
  end

end
