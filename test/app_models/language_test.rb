require_relative 'app_models_test_base'

class LanguageTest < AppModelsTestBase

  def setup
    super
    set_languages_root(tmp_root + '/' + 'languages')
    disk[languages.path].make
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  test '43EACE',
  "language's path has correct format" do
    @language = make_language(language_dir = 'C#', test_dir = 'NUnit')
    assert @language.path.match(language_dir + '/' + test_dir)
    assert correct_path_format?(@language)
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  test '43E75D',
  'filename_extension defaults to empty string when not set' do
    @language = make_language('C#', 'NUnit')
    spy_manifest({})
    assert_equal('', @language.filename_extension)
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  test '43E534',
  'filename_extension reads back as set' do
    @language = make_language('C#', 'NUnit')
    spy_manifest({ 'filename_extension' => '.cs' })
    assert_equal('.cs', @language.filename_extension)
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  test '43E6B4',
  'when :visible_filenames is empty array in manifest',
  'then visible_files is empty hash',
  'and visible_filenames is empty array' do
    @language = make_language('C#', 'NUnit')
    spy_manifest({ 'visible_filenames' => [] })
    assert_equal({}, @language.visible_files)
    assert_equal([], @language.visible_filenames)
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  test '43EDCE',
  'when :visible_filenames is non-empty array in manifest',
  'then visible_files are loaded but not output and not instructions' do
    @language = make_language('C#', 'NUnit')
    filename = 'test_untitled.cs'
    spy_manifest({ 'visible_filenames' => [filename] })
    disk[@language.path].write(filename, 'content')
    visible_files = @language.visible_files
    assert_equal({ filename => 'content' }, visible_files)
    assert_nil visible_files['output']
    assert_nil visible_files['instructions']
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  test '43ED66',
  'highlight_filenames defaults to [] when not set' do
    @language = make_language('C#', 'NUnit')
    spy_manifest({ 'visible_filenames' => ['test_untitled.cs'] })
    assert_equal [], @language.highlight_filenames
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  test '43EA75',
  'highlight_filenames reads back as set' do
    @language = make_language('C#', 'NUnit')
    visible_filenames = ['x.cs', 'y.cs']
    highlight_filenames = ['x.cs']
    spy_manifest({
        'visible_filenames' =>   visible_filenames,
      'highlight_filenames' => highlight_filenames
    })
    assert_equal highlight_filenames, @language.highlight_filenames
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  test '43ED8B',
  "lowlight_filenames defaults to",
  "['cyberdojo.sh','makefile','Makefile','unity.license.txt']",
  "when there is no entry for highlight_filenames" do
    @language = make_language('C#', 'NUnit')
    visible_filenames = ['wibble.cs', 'fubar.cs']
    spy_manifest({ 'visible_filenames' => visible_filenames })
    expected = ['cyber-dojo.sh', 'makefile', 'Makefile', 'unity.license.txt'].sort
    assert_equal expected, @language.lowlight_filenames.sort
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  test '43E855',
  'lowlight_filenames is visible_filenames - highlight_filenames',
  'when there is an entry for highlight_filenames' do
    @language = make_language('C++', 'assert')
    visible_filenames = ['wibble.hpp', 'wibble.cpp', 'fubar.hpp', 'fubar.cpp']
    highlight_filenames = ['wibble.hpp', 'wibble.cpp']
    spy_manifest({
        'visible_filenames' =>   visible_filenames,
      'highlight_filenames' => highlight_filenames
    })
    assert_equal ['fubar.cpp', 'fubar.hpp'], @language.lowlight_filenames.sort
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  test '43E292',
  'display_name reads back as set when not renamed' do
            name = 'C (gcc)-assert'
    display_name = 'C (gcc), assert'
    @language = make_language('C', 'assert')
    spy_manifest({ 'display_name' => display_name })
    assert_equal name, @language.name
    assert_equal display_name, @language.display_name
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  test '43EDC5',
  'image_name is read back as set' do
    @language = make_language('Ruby', 'Test::Unit')
    expected = 'cyberdojofoundation/language_ruby-1.9.3_test_unit'
    spy_manifest({ 'image_name' => expected })
    assert_equal expected, @language.image_name
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  test '43E90B',
  'tab_size is read back as set' do
    @language = make_language('Ruby', 'Test::Unit')
    tab_size = 9
    spy_manifest({ 'tab_size' => tab_size })
    assert_equal tab_size, @language.tab_size
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  test '43E690',
  'tab_size defaults to 4 when not set' do
    @language = make_language('Ruby', 'Test::Unit')
    spy_manifest({})
    assert_equal 4, @language.tab_size
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  test '43EC8D',
  'progress_regexs reads back as set' do
    @language = make_language('Ruby', 'Test::Unit')
    regexs = [
      "Errors \\((\\d)+ failures\\)",
      "OK \\((\\d)+ tests\\)"
    ]
    spy_manifest({
      'progress_regexs' => regexs
    })
    assert_equal regexs, @language.progress_regexs
    Regexp.new(regexs[0])
    Regexp.new(regexs[1])
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  test '43E3B5',
  'progress_regexs defaults to empty array' do
    @language = make_language('Ruby', 'Test::Unit')
    spy_manifest({})
    assert_equal [], @language.progress_regexs
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  test '43E89F',
  'bad JSON in manifest raises exception naming the language+test' do
    @language = make_language(ruby='Ruby', test_unit='TestUnit')
    dir = disk[@language.path]
    dir.make
    dir.write(manifest_filename, any_bad_json = '42')
    message = ''
    begin
      @language.tab_size
    rescue StandardError => ex
      message = ex.message
    end
    assert message.include?(ruby), message
    assert message.include?(test_unit), message
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  private

  def make_language(language_dir, test_dir)
    StartPoint.new(languages, tmp_root + '/' + language_dir + '/' + test_dir)
  end

  def spy_manifest(manifest)
    dir = disk[@language.path]
    dir.make
    dir.write_json(manifest_filename, manifest)
  end

  def manifest_filename
    'manifest.json'
  end

end
