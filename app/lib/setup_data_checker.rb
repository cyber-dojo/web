
require 'json'
require_relative './output_colour.rb'

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
      @manifest_filename = filename
      @manifest = manifest
      check_no_unknown_keys_exist
      check_all_required_keys_exist
      check_visible_filenames_is_valid
      check_highlight_filenames_is_valid
      check_display_name_is_valid
      check_image_name_is_valid
      check_unit_test_framework_is_valid
      check_progress_regexs_is_valid
      check_filename_extension_is_valid
    end
    errors
  end

  private

  # TODO: check there is at least one sub-dir with a manifest.json file
  # TODO: check at least one manifest has auto_pull:true ?

  def check_setup_json_meets_its_spec(manifest)
    type = manifest['type']
    if type.nil?
      @errors[setup_filename] << 'type: missing'
    elsif ! ['languages','exercises','instructions'].include? type
      @errors[setup_filename] << 'type: must be [languages|exercises|languages]'
    end
  end

  # - - - - - - - - - - - - - - - - - - - -

  def check_all_manifests_have_a_unique_display_name
    key = 'display_name'
    display_names = {}
    @manifests.each do |filename, manifest|
      display_name = manifest[key]
      display_names[display_name] ||= []
      display_names[display_name] << filename
    end
    display_names.each do |display_name, filenames|
      if filenames.size > 1
        filenames.each do |filename|
          @errors[filename] << "#{key}: duplicate '#{display_name}'"
        end
      end
    end
  end

  # - - - - - - - - - - - - - - - - - - - -

  def check_no_unknown_keys_exist
    known_keys = %w( display_name
                     filename_extension
                     highlight_filenames
                     image_name
                     progress_regexs
                     tab_size
                     unit_test_framework
                     visible_filenames
                   )
    @manifest.keys.each do |key|
      unless known_keys.include? key
        @key = key
        error 'unknown key'
      end
    end
  end

  # - - - - - - - - - - - - - - - - - - - -

  def check_all_required_keys_exist
    required_keys = %w( display_name
                        image_name
                        unit_test_framework
                        visible_filenames
                      )
    required_keys.each do |key|
      unless @manifest.keys.include? key
        @key = key
        error 'missing'
      end
    end
  end

  # - - - - - - - - - - - - - - - - - - - -

  def check_visible_filenames_is_valid
    @key = 'visible_filenames'
    return if visible_filenames.nil? # required-key different check
    # check its form
    if visible_filenames.class.name != 'Array'
      error 'must be an Array of Strings'
      return
    end
    if visible_filenames.any?{ |filename| filename.class.name != 'String' }
      error 'must be an Array of Strings'
      return
    end
    # check all visible files exist
    dir = File.dirname(@manifest_filename)
    visible_filenames.each do |filename|
      unless File.exists?(dir + '/' + filename)
        error "missing '#{filename}'"
      end
    end
    # check all files in dir are in visible_filenames
    dir = File.dirname(@manifest_filename)
    filenames = Dir.entries(dir).reject { |entry| File.directory?(entry) }
    filenames -= [ 'manifest.json' ]
    filenames.each do |filename|
      unless visible_filenames.include? filename
        error "missing '#{filename}'"
      end
    end
    # check cyber-dojo.sh is visible_filename
    unless visible_filenames.include? 'cyber-dojo.sh'
      error "must contain 'cyber-dojo.sh'"
    end
    # check no duplicate visible files
    visible_filenames.uniq.each do |filename|
      unless visible_filenames.count(filename) == 1
        error "duplicate '#{filename}'"
      end
    end
  end

  # - - - - - - - - - - - - - - - - - - - -

  def check_highlight_filenames_is_valid
    @key = 'highlight_filenames'
    return if highlight_filenames.nil? # it's optional
    # check its form
    if highlight_filenames.class.name != 'Array'
      error 'must be an Array'
      return
    end
    if highlight_filenames.any?{ |filename| filename.class.name != 'String' }
      error 'must be an Array of Strings'
      return
    end
    # check all are visible
    highlight_filenames.each do |h_filename|
      if visible_filenames.none? {|v_filename| v_filename == h_filename }
        error "'#{h_filename}' must be in visible_filenames"
      end
    end
    # check no duplicates
    highlight_filenames.uniq.each do |filename|
      unless highlight_filenames.count(filename) == 1
        error "duplicate '#{filename}'"
      end
    end
  end

  # - - - - - - - - - - - - - - - - - - - -

  def check_display_name_is_valid
    @key = 'display_name'
    return if display_name.nil? # required-key different check
    unless display_name.class.name == 'String'
      error 'must be a String'
      return
    end
    parts = display_name.split(',').select { |part| part.strip != '' }
    unless parts.length == 2
      error "not in 'A,B' format"
    end
  end

  # - - - - - - - - - - - - - - - - - - - -

  def check_image_name_is_valid
    @key = 'image_name'
    return if image_name.nil? # required-key different check
    unless image_name.class.name == 'String'
      error 'must be a String'
      return
    end
    if image_name == ''
      error 'is empty'
    end
  end

  # - - - - - - - - - - - - - - - - - - - -

  def check_unit_test_framework_is_valid
    @key = 'unit_test_framework'
    return if unit_test_framework.nil? # required-key different check
    unless unit_test_framework.class.name == 'String'
      error 'must be a String'
      return
    end
    if unit_test_framework == ''
      error 'is empty'
      return
    end
    has_parse_method = true
    begin
      OutputColour.of(unit_test_framework, any_output='xx')
    rescue
      has_parse_method = false
    end
    unless has_parse_method
      error "no OutputColour.parse_#{unit_test_framework} method"
    end
  end

  # - - - - - - - - - - - - - - - - - - - -

  def check_progress_regexs_is_valid
    @key = 'progress_regexs'
    return if progress_regexs.nil?  # it's optional
    if progress_regexs.class.name != 'Array'
      error 'must be an Array'
      return
    end
    if progress_regexs.length != 2
      error 'must contain 2 items'
      return
    end
    if progress_regexs.any? { |item| item.class.name != 'String' }
      error 'must contain 2 strings'
      return
    end
    progress_regexs.each do |s|
      begin
        Regexp.new(s)
      rescue
        error "cannot create regex from #{s}"
      end
    end

  end

  # - - - - - - - - - - - - - - - - - - - -

  def check_filename_extension_is_valid
    @key = 'filename_extension'
    return if filename_extension.nil? # it's optional
    if filename_extension.class.name != 'String'
      error 'must be a String'
      return
    end
    if filename_extension == ''
      error 'is empty'
      return
    end
    if filename_extension[0] != '.'
      error 'must start with a dot'
      return
    end
    if filename_extension == '.'
      error 'must be more than just a dot'
      return
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
      @errors[filename] << 'is missing'
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

  # - - - - - - - - - - - - - - - - - - - -

  def visible_filenames
    @manifest['visible_filenames']
  end

  def highlight_filenames
    @manifest['highlight_filenames']
  end

  def display_name
    @manifest['display_name']
  end

  def image_name
    @manifest['image_name']
  end

  def unit_test_framework
    @manifest['unit_test_framework']
  end

  def progress_regexs
    @manifest['progress_regexs']
  end

  def filename_extension
    @manifest['filename_extension']
  end

  def error(msg)
    @errors[@manifest_filename] << (@key + ': ' + msg)
  end

end
