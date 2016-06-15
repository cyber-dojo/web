
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

    #This is wrong. In an exercises volume you are very likely to have duplicate image_names
    #check_all_manifests_have_a_unique_image_name

    check_all_manifests_have_a_unique_display_name
    errors
  end

  private

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

=begin
    def check_all_manifests_have_a_unique_image_name
    # It's not unreasonable for two manifests to use the same docker image
    # But you can't do that. If necessary create an empty Dockerfile and
    # create an image with a different name.
    image_names = {}
    @manifests.each do |filename, manifest|
      image_name = manifest['image_name']
      image_names[image_name] ||= []
      image_names[image_name] << filename
    end
    image_names.each do |image_name, filenames|
      if filenames.size > 1
        filenames.each do |filename|
          @errors[filename] << "duplicate image_name:'#{image_name}'"
        end
      end
    end
  end
=end

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
