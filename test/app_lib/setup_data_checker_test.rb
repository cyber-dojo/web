#!/bin/bash ../test_wrapper.sh

require_relative './app_lib_test_base'
require 'json'

class SetupDataCheckerTest < AppLibTestBase


  # test_data master (instructions) has no errors  ... hmm split into two?

  test '0C1F2F',
  'test_data master (manifested) has no errors' do
    checker = SetupDataChecker.new(setup_data_path + '/languages')
    errors = checker.check
    assert_zero errors
    assert_equal 5, checker.manifests.size
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
      assert_error junit_manifest_filename,    "duplicate display_name:'Java, JUnit'"
      assert_error cucumber_manifest_filename, "duplicate display_name:'Java, JUnit'"
    end
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  test '67307A',
  'file not present in visible_filename is diagnosed as error' do
    copy_good_master_to('67307A') do |tmp_dir|
      # peturb
      junit_manifest_filename = "#{tmp_dir}/Java/JUnit/manifest.json"
      IO.write("#{tmp_dir}/Java/JUnit/new_file.jj", 'hello world')
      check
      assert_error junit_manifest_filename, 'new_file.jj not present in visible_filenames:'
    end
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  test '243554',
  'missing required key is diagnosed as error' do
    missing_require_key = lambda do |key|
      copy_good_master_to('243554_'+key) do |tmp_dir|
        # peturb
        junit_manifest_filename = "#{tmp_dir}/Java/JUnit/manifest.json"
        content = IO.read(junit_manifest_filename)
        junit_manifest = JSON.parse(content)
        assert junit_manifest.keys.include? key
        junit_manifest.delete(key)
        IO.write(junit_manifest_filename, JSON.unparse(junit_manifest))
        check
        assert_error junit_manifest_filename, "missing required key '#{key}'"
      end
    end
    required_keys = %w( display_name
                        image_name
                        unit_test_framework
                        visible_filenames
                      )
    required_keys.each { |key| missing_require_key.call(key) }
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  test 'C27D67',
  'display_name not a String is diagnosed as error' do
    copy_good_master_to('C27D67') do |tmp_dir|
      # peturb
      junit_manifest_filename = "#{tmp_dir}/Java/JUnit/manifest.json"
      content = IO.read(junit_manifest_filename)
      junit_manifest = JSON.parse(content)
      junit_manifest['display_name'] = [ 1 ]
      IO.write(junit_manifest_filename, JSON.unparse(junit_manifest))
      check
      assert_error junit_manifest_filename, 'display_name must be a String'
    end
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  test 'ABD942',
  'invalid display_name is diagnosed as error' do
    bad_display_name = lambda do |bad|
      copy_good_master_to('ABD942') do |tmp_dir|
        # peturn
        junit_manifest_filename = "#{tmp_dir}/Java/JUnit/manifest.json"
        content = IO.read(junit_manifest_filename)
        junit_manifest = JSON.parse(content)
        junit_manifest['display_name'] = bad
        IO.write(junit_manifest_filename, JSON.unparse(junit_manifest))
        check
        assert_error junit_manifest_filename, "display_name not in 'A,B' format"
      end
    end
    bad_display_name.call('')
    bad_display_name.call('no comma')
    bad_display_name.call('one,two,commas')
    bad_display_name.call(',nothing to left')
    bad_display_name.call('nothing to right,')
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  test 'A9D696',
  'image_name not a String is diagnosed as error' do
    copy_good_master_to('A9D696') do |tmp_dir|
      # peturb
      junit_manifest_filename = "#{tmp_dir}/Java/JUnit/manifest.json"
      content = IO.read(junit_manifest_filename)
      junit_manifest = JSON.parse(content)
      junit_manifest['image_name'] = [ 1 ]
      IO.write(junit_manifest_filename, JSON.unparse(junit_manifest))
      check
      assert_error junit_manifest_filename, 'image_name must be a String'
    end
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  test '75CBD4',
  'empty image_name is diagnosed as error' do
    copy_good_master_to('75CBD4') do |tmp_dir|
      # peturn
      junit_manifest_filename = "#{tmp_dir}/Java/JUnit/manifest.json"
      content = IO.read(junit_manifest_filename)
      junit_manifest = JSON.parse(content)
      junit_manifest['image_name'] = ''
      IO.write(junit_manifest_filename, JSON.unparse(junit_manifest))
      check
      assert_error junit_manifest_filename, "image_name is empty"
    end
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  test '748CC7',
  'unknown key is diagnosed as error' do
    copy_good_master_to('748CC7') do |tmp_dir|
      # peturn
      junit_manifest_filename = "#{tmp_dir}/Java/JUnit/manifest.json"
      content = IO.read(junit_manifest_filename)
      junit_manifest = JSON.parse(content)
      junit_manifest['salmon'] = 'hello'
      IO.write(junit_manifest_filename, JSON.unparse(junit_manifest))
      check
      assert_error junit_manifest_filename, "unknown key 'salmon'"
    end
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  test '1FEC31',
  'missing visible file is diagnosed as error' do
    copy_good_master_to('1FEC31') do |tmp_dir|
      # peturn
      junit_manifest_filename = "#{tmp_dir}/Java/JUnit/manifest.json"
      content = IO.read(junit_manifest_filename)
      junit_manifest = JSON.parse(content)
      missing_filename = junit_manifest['visible_filenames'][0]
      File.delete("#{tmp_dir}/Java/JUnit/#{missing_filename}")
      check
      assert_error junit_manifest_filename, "missing visible_filename '#{missing_filename}'"
    end
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  test '685935',
  'duplicate visible file is diagnosed as error' do
    copy_good_master_to('685935') do |tmp_dir|
      # peturn
      junit_manifest_filename = "#{tmp_dir}/Java/JUnit/manifest.json"
      content = IO.read(junit_manifest_filename)
      junit_manifest = JSON.parse(content)
      visible_filenames = junit_manifest['visible_filenames']
      duplicate_filename = visible_filenames[0]
      visible_filenames << duplicate_filename
      junit_manifest['visible_filenames'] = visible_filenames
      IO.write(junit_manifest_filename, JSON.unparse(junit_manifest))
      check
      assert_error junit_manifest_filename, "duplicate visible_filename '#{duplicate_filename}'"
    end
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  test '2B1623',
  'invalid progress_regexs is diagnosed as error' do
    bad_progress_regexs = lambda do |bad, expected|
      copy_good_master_to('2B1623') do |tmp_dir|
        # peturn
        junit_manifest_filename = "#{tmp_dir}/Java/JUnit/manifest.json"
        content = IO.read(junit_manifest_filename)
        junit_manifest = JSON.parse(content)
        junit_manifest['progress_regexs'] = bad
        IO.write(junit_manifest_filename, JSON.unparse(junit_manifest))
        check
        assert_error junit_manifest_filename, expected
      end
    end
    bad_progress_regexs.call({}, 'progress_regexs: must be an Array')
    bad_progress_regexs.call([], 'progress_regexs: must contain 2 items')
    bad_progress_regexs.call([1,2], 'progress_regexs: must contain 2 strings')
    bad_progress_regexs.call(['(\\','ok'], 'progress_regexs: cannot create regex from (\\')
    bad_progress_regexs.call(['ok','(\\'], 'progress_regexs: cannot create regex from (\\')
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  test '2F9E46',
  'bad shell command raises' do
    assert_raises(RuntimeError) { shell 'sdsdsdsd' }
  end

  private # = = = = = = = = = = = = = = = = = = = = = = = = = =

  def copy_good_master_to(id)
    Dir.mktmpdir('cyber-dojo-' + id) do |tmp_dir|
      shell "cp -r #{setup_data_path}/languages/* #{tmp_dir}"
      @tmp_dir = tmp_dir
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
    assert_equal expected, messages[0]
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  def assert_zero(errors)
    diagnostic = ''
    count = 0
    errors.each do |filename,messages|
      diagnostic += filename if messages.size != 0
      messages.each { |message| diagnostic += ("\t" + message + "\n") }
      count += messages.size
    end
    assert_equal 0, count, diagnostic
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
