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
  # setup.json
  # - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  test 'C6D738',
  'missing setup.json is an error' do
    copy_good_master_to('C6D738') do |tmp_dir|
      setup_filename = "#{tmp_dir}/setup.json"
      shell "mv #{setup_filename} #{tmp_dir}/setup.json.missing"
      check
      assert_error setup_filename, 'missing'
    end
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  test '2F42DF',
  'bad json in root setup.json is an error' do
    copy_good_master_to('2F42DF') do |tmp_dir|
      setup_filename = "#{tmp_dir}/setup.json"
      IO.write(setup_filename, any_bad_json)
      check
      assert_error setup_filename, 'bad JSON'
    end
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  test '28599A',
  'setup.json with no type is an error' do
    copy_good_master_to('28599A') do |tmp_dir|
      setup_filename = "#{tmp_dir}/setup.json"
      IO.write(setup_filename, '{}')
      check
      assert_error setup_filename, 'no type: entry'
    end
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  test 'D7B64D',
  'setup.json with bad type is an error' do
    copy_good_master_to('D7B64D') do |tmp_dir|
      setup_filename = "#{tmp_dir}/setup.json"
      IO.write(setup_filename, JSON.unparse({
        'type' => 'salmon'
      }))
      check
      assert_error setup_filename, 'type: must be [languages|exercises|languages]'
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
  # manifest.json
  # - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  test '1A351C',
  'bad json in a manifest.json file is an error' do
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
  'manifests with the same display_name is an error' do
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
      assert_error junit_manifest_filename,    "display_name: duplicate 'Java, JUnit'"
      assert_error cucumber_manifest_filename, "display_name: duplicate 'Java, JUnit'"
    end
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  # unknown keys
  # - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  test '748CC7',
  'unknown key is an error' do
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
  # missing required keys
  # - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  test '243554',
  'missing required key is an error' do
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
        assert_error junit_manifest_filename, "#{key}: missing"
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
  # required-key: display_name
  # - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  test 'ABD942',
  'invalid display_name is an error' do
    tid = 'ABD942'
    key = 'display_name'
    replace_in_manifest(tid, key, 1               , key + ': must be a String')
    replace_in_manifest(tid, key, ''              , key + ": not in 'A,B' format")
    replace_in_manifest(tid, key, 'no comma'      , key + ": not in 'A,B' format")
    replace_in_manifest(tid, key, 'one,two,commas', key + ": not in 'A,B' format")
    replace_in_manifest(tid, key, ',right only'   , key + ": not in 'A,B' format")
    replace_in_manifest(tid, key, 'left only,'    , key + ": not in 'A,B' format")
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  # required-key: image_name
  # - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  test 'A9D696',
  'invalid image_name not an error' do
    tid = 'A9D696'
    key = 'image_name'
    replace_in_manifest(tid, key, 1    , key + ': must be a String')
    replace_in_manifest(tid, key, [ 1 ], key + ': must be a String')
    replace_in_manifest(tid, key, ''   , key + ': is empty')
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  # required-key: unit_test_framework
  # - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  test 'B84696',
  'invalid unit_test_framework is an error' do
    tid = 'B84696'
    key = 'unit_test_framework'
    replace_in_manifest(tid, key, 1    , key + ': must be a String')
    replace_in_manifest(tid, key, [ 1 ], key + ': must be a String')
    replace_in_manifest(tid, key, ''   , key + ': is empty')
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  # required-key: visible_filenames
  # - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  test 'E6D4DE',
  'visible_filenames not an Array of Strings is an error' do
    key = 'visible_filenames'
    bad_visible_filenames = lambda do |value|
      copy_good_master_to('E6D4DE') do |tmp_dir|
        # peturb
        junit_manifest_filename = "#{tmp_dir}/Java/JUnit/manifest.json"
        content = IO.read(junit_manifest_filename)
        junit_manifest = JSON.parse(content)
        junit_manifest[key] = value
        IO.write(junit_manifest_filename, JSON.unparse(junit_manifest))
        check
        assert_error junit_manifest_filename, key + ': must be an Array of Strings'
      end
    end
    bad_visible_filenames.call(1)
    bad_visible_filenames.call([1])
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  test '67307A',
  'file in dir not present in visible_filename is an error' do
    copy_good_master_to('67307A') do |tmp_dir|
      # peturb
      junit_manifest_filename = "#{tmp_dir}/Java/JUnit/manifest.json"
      IO.write("#{tmp_dir}/Java/JUnit/new_file.jj", 'hello world')
      check
      assert_error junit_manifest_filename, 'visible_filenames: new_file.jj not present'
    end
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  test '1FEC31',
  'missing visible file is an error' do
    copy_good_master_to('1FEC31') do |tmp_dir|
      # peturn
      junit_manifest_filename = "#{tmp_dir}/Java/JUnit/manifest.json"
      content = IO.read(junit_manifest_filename)
      junit_manifest = JSON.parse(content)
      missing_filename = junit_manifest['visible_filenames'][0]
      File.delete("#{tmp_dir}/Java/JUnit/#{missing_filename}")
      check
      assert_error junit_manifest_filename, "visible_filenames: missing '#{missing_filename}'"
    end
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  test '685935',
  'duplicate visible file is an error' do
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
      assert_error junit_manifest_filename, "visible_filenames: duplicate '#{duplicate_filename}'"
    end
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  # optional-key: progress_regexs
  # - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  test '2B1623',
  'invalid progress_regexs is an error' do
    tid = '2B1623'
    key = 'progress_regexs'
    bad_regex = '(\\'
    replace_in_manifest(tid, key, 1               , key + ': must be an Array')
    replace_in_manifest(tid, key, []              , key + ': must contain 2 items')
    replace_in_manifest(tid, key, [1,2]           , key + ': must contain 2 strings')
    replace_in_manifest(tid, key, [bad_regex,'ok'], key + ": cannot create regex from #{bad_regex}")
    replace_in_manifest(tid, key, ['ok',bad_regex], key + ": cannot create regex from #{bad_regex}")
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  test '2F9E46',
  'bad shell command raises' do
    assert_raises(RuntimeError) { shell 'sdsdsdsd' }
  end

  private # = = = = = = = = = = = = = = = = = = = = = = = = = =

  def replace_in_manifest(tid, key, bad, expected)
    copy_good_master_to('ABD942') do |tmp_dir|
      # peturn
      junit_manifest_filename = "#{tmp_dir}/Java/JUnit/manifest.json"
      content = IO.read(junit_manifest_filename)
      junit_manifest = JSON.parse(content)
      junit_manifest[key] = bad
      IO.write(junit_manifest_filename, JSON.unparse(junit_manifest))
      check
      assert_error junit_manifest_filename, expected
    end
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

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
