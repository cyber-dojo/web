#!/bin/bash ../test_wrapper.sh

require_relative './app_lib_test_base'
require 'json'

class SetupDataCheckerTest < AppLibTestBase

  # test bad shell command raises

  test '0C1F2F',
  'test_data master (manifested) has no errors' do
    checker = SetupDataChecker.new(setup_data_path)
    checker.check
    assert_zero checker.errors
    assert_equal 5, checker.manifests.size
  end

  # test_data master (instructions) has no errors  ... hmm split into two?

  # test that mal-formed manifest.json file is seen as checker error and not test exception

  test '6F36A3',
  'manifests with the same image_name are detected' do
    Dir.mktmpdir('cyber-dojo-6F36A3') do |tmp_dir|
      # copy master data to tmp_dir
      shell "cp -r #{setup_data_path}/* #{tmp_dir}"
      # peturb copy appropriately
      junit_manifest_filename = "#{tmp_dir}/Java/JUnit/manifest.json"
      content = IO.read(junit_manifest_filename)
      junit_manifest = JSON.parse(content)
      junit_image_name = junit_manifest['image_name']
      cucumber_manifest_filename = "#{tmp_dir}/Java/Cucumber/manifest.json"
      content = IO.read(cucumber_manifest_filename)
      cucumber_manifest = JSON.parse(content)
      cucumber_manifest['image_name'] = junit_image_name
      IO.write(cucumber_manifest_filename, JSON.unparse(cucumber_manifest))
      # check peturbation
      @checker = SetupDataChecker.new(tmp_dir)
      @checker.check_all_manifests_have_a_unique_image_name
      assert_error junit_manifest_filename, 'duplicate image_name'
      assert_error cucumber_manifest_filename, 'duplicate image_name'
    end
  end

  test '2C7CFC',
  'manifests with the same display_name are detected' do
    Dir.mktmpdir('cyber-dojo-2C7CFC') do |tmp_dir|
      # copy master data to tmp_dir
      shell "cp -r #{setup_data_path}/* #{tmp_dir}"
      # peturb copy appropriately
      junit_manifest_filename = "#{tmp_dir}/Java/JUnit/manifest.json"
      content = IO.read(junit_manifest_filename)
      junit_manifest = JSON.parse(content)
      junit_display_name = junit_manifest['display_name']
      cucumber_manifest_filename = "#{tmp_dir}/Java/Cucumber/manifest.json"
      content = IO.read(cucumber_manifest_filename)
      cucumber_manifest = JSON.parse(content)
      cucumber_manifest['display_name'] = junit_display_name
      IO.write(cucumber_manifest_filename, JSON.unparse(cucumber_manifest))
      # check peturbation
      @checker = SetupDataChecker.new(tmp_dir)
      @checker.check_all_manifests_have_a_unique_display_name
      assert_error junit_manifest_filename, 'duplicate display_name'
      assert_error cucumber_manifest_filename, 'duplicate display_name'
    end
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  private

  def assert_zero(errors)
    count = 0
    errors.each do |filename,messages|
      puts filename if messages.size != 0
      messages.each { |message| puts "\t" + message }
      count += messages.size
    end
    assert_equal 0, count
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  def assert_error filename, expected
    errors = @checker.errors
    messages = errors[filename]
    assert_equal 'Array', messages.class.name
    assert_equal 1, messages.size, "no errors for #{filename}"
    assert messages[0].include?(expected), "expected[#{expected}] in #{messages}"
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  def shell(command)
    output = `#{command}`
    if $?.exitstatus != 0
      fail "#{command} returned non-zero (#{$?.exitstatus}): output: #{output}"
    end
    output
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  def setup_data_path
    File.expand_path(File.dirname(__FILE__)) + '/setup_data'
  end

end
