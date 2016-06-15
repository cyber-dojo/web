#!/bin/bash ../test_wrapper.sh

require_relative './app_lib_test_base'
require 'json'

class SetupDataCheckerTest < AppLibTestBase


  # test_data master (instructions) has no errors  ... hmm split into two?

  test '0C1F2F',
  'test_data master (manifested) has no errors' do
    checker = SetupDataChecker.new(setup_data_path)
    errors = checker.check
    assert_zero errors
    assert_equal 6, checker.manifests.size
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  test 'C6D738',
  'missing setup.json is diagnosed as error' do
    copy_good_master_to('C6D738') do |tmp_dir|
      setup_filename = "#{tmp_dir}/setup.json"
      shell "mv #{setup_filename} #{tmp_dir}/setup.json.missing"
      check
      assert_error setup_filename, 'missing'
    end
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  test '2F42DF',
  'bad json in root setup.json is diagnosed as error' do
    copy_good_master_to('2F42DF') do |tmp_dir|
      setup_filename = "#{tmp_dir}/setup.json"
      IO.write(setup_filename, any_bad_json)
      check
      assert_error setup_filename, 'bad JSON'
    end
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  test '28599A',
  'setup.json with no type is diagnosed as error' do
    copy_good_master_to('28599A') do |tmp_dir|
      setup_filename = "#{tmp_dir}/setup.json"
      IO.write(setup_filename, '{}')
      check
      assert_error setup_filename, 'no type: entry'
    end
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  test 'D7B64D',
  'setup.json with bad type is diagnosed as error' do
    copy_good_master_to('D7B64D') do |tmp_dir|
      setup_filename = "#{tmp_dir}/setup.json"
      IO.write(setup_filename, JSON.unparse({
        'type' => 'salmon'
      }))
      check
      assert_error setup_filename, 'bad type: entry'
    end
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  #test '1B01F7',
  # 'setup.json for exercises with no lhs-column-title is diagnosed as error' do
  # end

  # test '993BE1',
  # 'setup.json for exercises with no rhs-column-title is diagnosed as error' do
  # end

  # - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  test '1A351C',
  'bad json in a manifest.json file is diagnosed as error' do
    copy_good_master_to('1A351C') do |tmp_dir|
      junit_manifest_filename = "#{tmp_dir}/Java/JUnit/manifest.json"
      IO.write(junit_manifest_filename, any_bad_json)
      check
      assert_nil @checker.manifests[junit_manifest_filename]
      assert_error junit_manifest_filename, 'bad JSON'
    end
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  test '2C7CFC',
  'manifests with the same display_name is diagnosed as error' do
    copy_good_master_to('2C7CFC') do |tmp_dir|
      # peturb
      junit_manifest_filename = "#{tmp_dir}/Java/JUnit/manifest.json"
      content = IO.read(junit_manifest_filename)
      junit_manifest = JSON.parse(content)
      junit_display_name = junit_manifest['display_name']
      cucumber_manifest_filename = "#{tmp_dir}/Java/Cucumber/manifest.json"
      content = IO.read(cucumber_manifest_filename)
      cucumber_manifest = JSON.parse(content)
      cucumber_manifest['display_name'] = junit_display_name
      IO.write(cucumber_manifest_filename, JSON.unparse(cucumber_manifest))
      check
      assert_error junit_manifest_filename, 'duplicate display_name'
      assert_error cucumber_manifest_filename, 'duplicate display_name'
    end
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  # ...

  # - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  test '2F9E46',
  'bad shell command raises' do
    assert_raises(RuntimeError) { shell 'sdsdsdsd' }
  end

  private # = = = = = = = = = = = = = = = = = = = = = = = = = =

  def copy_good_master_to(id)
    Dir.mktmpdir('cyber-dojo-' + id) do |tmp_dir|
      @tmp_dir = tmp_dir
      shell "cp -r #{setup_data_path}/* #{tmp_dir}"
      yield tmp_dir
    end
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  def check
    @checker = SetupDataChecker.new(@tmp_dir)
    @checker.check
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  def assert_error filename, expected
    messages = @checker.errors[filename]
    assert_equal 'Array', messages.class.name
    assert_equal 1, messages.size, "no errors for #{filename}!"
    assert messages[0].include?(expected), "expected[#{expected}] in #{messages}"
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

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

  def shell(command)
    `#{command}`
  rescue
    raise RuntimeError.new("#{command} returned non-zero (#{$?.exitstatus})")
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  def setup_data_path
    File.expand_path(File.dirname(__FILE__)) + '/setup_data'
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  def any_bad_json
    'xxx'
  end

end
