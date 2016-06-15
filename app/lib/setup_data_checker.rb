
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
    if fill_manifest(setup_filename)
      check_setup_json_meets_its_spec
    end

    Dir.glob("#{@path}/**/manifest.json").each do |filename|
      fill_manifest(filename)
    end

    check_all_manifests_have_a_unique_display_name
    errors
  end

  private

  # TODO: check there is at least one sub-dir with a manifest.json file
  # TODO: check at least one manifest has auto_pull:true ?

  def check_setup_json_meets_its_spec
    manifest = @manifests[setup_filename]
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

  def setup_filename
    @path + '/setup.json'
  end

  # - - - - - - - - - - - - - - - - - - - -

  def fill_manifest(filename)
    @errors[filename] = []
    if ! File.exists?(filename)
      @errors[filename] << 'missing'
      return false
    end

    begin
      content = IO.read(filename)
      @manifests[filename] = JSON.parse(content)
      return true
    rescue JSON::ParserError
      @errors[filename] << 'bad JSON'
    end
    return false
  end

end
