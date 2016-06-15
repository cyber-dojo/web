
require 'json'

class SetupDataChecker

  def initialize(path)
    @path = path.chomp('/')
    @manifests = {}
    @errors = { setup_path => [] }
    Dir.glob("#{path}/**/manifest.json").each do |filename|
      @errors[filename] = []
      fill_manifest(filename)
    end
  end

  attr_reader :manifests # mapped per manifest-filename
  attr_reader :errors    # mapped per manifest-filename

  # - - - - - - - - - - - - - - - - - - - -

  def check
    check_root_setup_json_exists
    check_root_setup_json_ness
    check_all_manifests_have_a_unique_image_name
    check_all_manifests_have_a_unique_display_name
    errors
  end

  # - - - - - - - - - - - - - - - - - - - -

  def check_root_setup_json_exists
    @errors[setup_path] << 'missing' unless File.exists?(setup_path)
    errors
  end

  # - - - - - - - - - - - - - - - - - - - -

  def check_root_setup_json_ness
    fill_manifest(setup_path)
    errors
  end

  # - - - - - - - - - - - - - - - - - - - -

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
    errors
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
    errors
  end

  # - - - - - - - - - - - - - - - - - - - -

  private

  def setup_path
    @path + '/setup.json'
  end

  def fill_manifest(filename)
    content = IO.read(filename)
    @manifests[filename] = JSON.parse(content)
  rescue JSON::ParserError
    @errors[filename] << 'bad JSON'
  end

end
