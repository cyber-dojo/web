#!/bin/bash ../test_wrapper.sh

require_relative './languages_test_base'

class LanguagesManifestsTests < LanguagesTestBase

  test '8B45E1',
  'no known flaws in manifests of any language/test/' do
    manifests = Dir.glob("#{languages.path}/**/manifest.json").sort
    manifests.each do |filename|
      dir = File.dirname(filename)
      @language = dir
      assert created_kata_manifests_language_entry_round_trips?
    end
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  def created_kata_manifests_language_entry_round_trips?
    language = languages[display_name]
    assert !language.nil?, "!language.nil? display_name=#{display_name}"

    manifest = katas.create_kata_manifest(language)
    kata = katas.create_kata_from_kata_manifest(manifest)
    lang = kata.language
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
    print '.'
    true
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  def display_name
    manifest_property
  end

  def false_puts_alert(message)
    puts_alert message
    false
  end

  def puts_alert(message)
    puts alert + '  ' + message
  end

  def alert
    "\n>>>>>>> #{language_dir} <<<<<<<\n"
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

  def manifest_property
    property_name = /`(?<name>[^']*)/ =~ caller[0] && name
    manifest[property_name]
  end

end
