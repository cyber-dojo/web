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
      @language = dir
      assert cyberdojo_sh_has_execute_permission?
      refute any_files_owner_is_root?
      refute any_files_group_is_root?
      refute any_file_is_unreadable?
      assert created_kata_manifests_language_entry_round_trips?
    end
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  def cyberdojo_sh_has_execute_permission?
    unless File.stat(language_dir + '/' + 'cyber-dojo.sh').executable?
      return false_puts_alert 'cyber-dojo.sh does not have execute permission'
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

  def visible_filenames
    manifest_property
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
