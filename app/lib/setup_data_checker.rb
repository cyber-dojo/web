
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
    manifest = json_manifest(setup_filename)
    check_setup_json_meets_its_spec(manifest) unless manifest.nil?
    Dir.glob("#{@path}/**/manifest.json").each do |filename|
      manifest = json_manifest(filename)
      @manifests[filename] = manifest unless manifest.nil?
    end
    # TODO: instructions-checks are different to languages/exercises checks
    check_all_manifests_have_a_unique_display_name
    @manifests.each do |filename, manifest|
      check_all_files_present_in_visible_filenames(filename, manifest)
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
    else
      if ! ['languages','exercises','instructions'].include? type
        @errors[setup_filename] << 'bad type: entry'
      end
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

  def check_all_files_present_in_visible_filenames(manifest_filename, manifest)
    dir = File.dirname(manifest_filename)
    visible_filenames = manifest['visible_filenames']
    filenames = Dir.entries(dir).reject { |entry| File.directory?(entry) }
    filenames -= [ 'manifest.json' ]
    filenames.each do |filename|
      unless visible_filenames.include? filename
        @errors[manifest_filename] << "#{filename} not present in visible_filenames:"
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
