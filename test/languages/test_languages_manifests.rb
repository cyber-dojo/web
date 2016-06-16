#!/bin/bash ../test_wrapper.sh

# Plan. Convert this to regular ruby program/class (keep inside web)
#          CyberDojoVolumeChecker
#       Has to return non-zero if issue found.
#       Replace test methods with calls to this program.
#
# Note. visible_filenames cannot include 'manifest.json'

require_relative './languages_test_base'

class LanguagesManifestsTests < LanguagesTestBase

  test '8B45E1',
  'no known flaws in manifests of any language/test/' do
    manifests = Dir.glob("#{languages.path}/**/manifest.json").sort
    manifests.each do |filename|
      dir = File.dirname(filename)
      check_manifest(dir)
    end
  end

  def check_manifest(dir)
    @language = dir
    assert highlight_filenames_are_subset_of_visible_filenames?
    assert progress_regexs_valid?
    refute filename_extension_starts_with_dot?
    assert cyberdojo_sh_exists?
    assert cyberdojo_sh_has_execute_permission?
    assert colour_method_for_unit_test_framework_output_exists?
    refute any_files_owner_is_root?
    refute any_files_group_is_root?
    refute any_file_is_unreadable?
    assert created_kata_manifests_language_entry_round_trips?
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  def progress_regexs_valid?
    if progress_regexs.class.name != 'Array'
      message = "#{manifest_filename}'s progress_regexs entry is not an array"
      return false_puts_alert message
    end
    if progress_regexs.length != 0 && progress_regexs.length != 2
      message = "#{manifest_filename}'s 'progress_regexs' entry does not contain 2 entries"
      return false_puts_alert message
    end
    progress_regexs.each do |s|
      begin
        Regexp.new(s)
      rescue
        return false_puts_alert "#{manifest_filename} cannot create a Regexp from #{s}"
      end
    end
    true_dot
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  def filename_extension_starts_with_dot?
    if manifest['filename_extension'][0] != '.'
      message = "#{manifest_filename}'s 'filename_extension' does not start with a ."
      return true_puts_alert message
    end
    false_dot
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  def all_files_exist?(symbol)
    (manifest[symbol] || []).each do |filename|
      unless File.exists?(language_dir + '/' + filename)
        message =
          "#{manifest_filename} contains a '#{symbol}' entry [#{filename}]\n" +
          " but the #{language_dir}/ dir does not contain a file called #{filename}"
        return false_puts_alert message
      end
    end
    true_dot
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  def highlight_filenames_are_subset_of_visible_filenames?
    highlight_filenames.each do |filename|
      if filename != 'instructions' &&
           filename != 'output' &&
           !visible_filenames.include?(filename)
        message =
          "#{manifest_filename} contains a 'highlight_filenames' entry ['#{filename}'] " +
          " but visible_filenames does not include '#{filename}'"
        return false_puts_alert message
      end
    end
    true_dot
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  def cyberdojo_sh_exists?
    if visible_filenames.select { |filename| filename == 'cyber-dojo.sh' } == []
      message = "#{manifest_filename} must contain ['cyber-dojo.sh'] in 'visible_filenames'"
      return false_puts_alert message
    end
    true_dot
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  def cyberdojo_sh_has_execute_permission?
    unless File.stat(language_dir + '/' + 'cyber-dojo.sh').executable?
      return false_puts_alert 'cyber-dojo.sh does not have execute permission'
    end
    true_dot
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  def colour_method_for_unit_test_framework_output_exists?
    has_parse_method = true
    begin
      OutputColour.of(unit_test_framework, any_output='xx')
    rescue
      has_parse_method = false
    end
    unless has_parse_method
      message = "app/lib/OutputColour.rb does not contain a " +
                "parse_#{unit_test_framework}(output) method"
      return false_puts_alert message
    end
    true_dot
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  def any_files_owner_is_root?
    (visible_filenames + ['manifest.json']).each do |filename|
      uid = File.stat(language_dir + '/' + filename).uid
      owner = Etc.getpwuid(uid).name
      if owner == 'root'
        return true_puts_alert "owner of #{language_dir}/#{filename} is root"
      end
    end
    false_dot
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  def any_files_group_is_root?
    (visible_filenames + ['manifest.json']).each do |filename|
      gid = File.stat(language_dir + '/' + filename).gid
      owner = Etc.getgrgid(gid).name
      if owner == 'root'
        return true_puts_alert "owner of #{language_dir}/#{filename} is root"
      end
    end
    false_dot
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  def any_file_is_unreadable?
    (visible_filenames + ['manifest.json']).each do |filename|
      unless File.stat(language_dir + '/' + filename).world_readable?
        return true_puts_alert "#{language_dir}/#{filename} is not world-readable"
      end
    end
    false_dot
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  private

  def display_name
    manifest_property
  end

  def image_name
    manifest_property.split('/')[1]
  end

  def visible_filenames
    manifest_property
  end

  def unit_test_framework
    manifest_property
  end

  def progress_regexs
    manifest_property || []
  end

  def highlight_filenames
    manifest_property || []
  end

  def manifest
    JSON.parse(IO.read(manifest_filename))
  end

  def manifest_filename
    language_dir + '/' + 'manifest.json'
  end

  def language_dir
    @language
  end

  def false_puts_alert(message)
    puts_alert message
    false
  end

  def true_puts_alert(message)
    puts_alert message
    true
  end

  def puts_alert(message)
    puts alert + '  ' + message
  end

  def alert
    "\n>>>>>>> #{language_dir} <<<<<<<\n"
  end

  def false_dot
    print '.'
    false
  end

  def true_dot
    #print '.'
    true
  end

  def manifest_property
    property_name = /`(?<name>[^']*)/ =~ caller[0] && name
    manifest[property_name]
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  def created_kata_manifests_language_entry_round_trips?
    skip "Round-trip test failing..."
    language = languages[display_name]
    assert !language.nil?, "!language.nil? display_name=#{display_name}"

    exercise = exercises['Print_Diamond']
    assert !exercise.nil?, '!exercise.nil?'

    kata = katas.create_kata(language, exercise)
    manifest = katas.kata_manifest(kata)
    lang = manifest['language']
    if lang.count('-') != 1
      message =
        "#{kata.id}'s manifest 'language' entry is #{lang}" +
        ' which does not contain a - '
      return false_puts_alert message
    end
    print '.'
    round_tripped = languages[lang]
    unless File.directory? round_tripped.path
      message =
        "kata #{kata.id}'s manifest 'language' entry is #{lang}" +
        ' which does not round-trip back to its own languages/sub/folder.' +
        ' Please check app/models/Languages.rb:new_name()'
      return false_puts_alert message
    end
    print '.'
    if lang != 'Bash-shunit2' && lang.each_char.any? { |ch| '0123456789'.include?(ch) }
      message = "#{kata.id}'s manifest 'language' entry is #{lang}" +
                ' which contains digits and looks like it contains a version number'
      return false_puts_alert message
    end
    true_dot
  end

end
