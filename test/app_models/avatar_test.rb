require_relative 'app_models_test_base'
require_relative '../app_lib/delta_maker'

class AvatarTest < AppModelsTestBase

  def self.hex_prefix
    'FB7A42'
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  test 'E81',
  "an avatar's kata is the kata it was created with" do
    kata = make_language_kata
    avatar = kata.start_avatar
    assert_equal kata.id, avatar.kata.id
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  test 'D2B',
  "an avatar's' initial visible_files are:",
  '1. the language visible_files,',
  '2. the exercise instructions,',
  '3. empty output' do
    kata = make_language_kata({ 'display_name' => 'C (gcc), assert' })
    avatar = kata.start_avatar
    expected = %w(
      cyber-dojo.sh
      hiker.c
      hiker.h
      hiker.tests.c
      instructions
      makefile
      output
    )
    assert_equal expected, avatar.visible_filenames.sort
    assert_equal '', avatar.visible_files['output']
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  test '92F',
  'when an avatar has zero traffic-lights it is not active?' do
    kata = make_language_kata
    lion = kata.start_avatar(['lion'])
    assert_equal [], lion.lights
    refute lion.active?
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  test 'BAB',
  'when an avatar has one or more traffic-lights it is active?' do
    kata = make_language_kata
    lion = kata.start_avatar(['lion'])
    DeltaMaker.new(lion).run_test
    assert_equal 1, lion.lights.length
    assert lion.active?
    DeltaMaker.new(lion).run_test
    assert_equal 2, lion.lights.length
    assert lion.active?
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  test '0CA',
  'test() output is added to visible_files' do
    kata = make_language_kata
    @avatar = kata.start_avatar
    visible_files = @avatar.visible_files
    assert visible_files.keys.include?('output')
    assert_equal '', visible_files['output']
    runner.stub_run(expected = 'helloWorld')
    _, @visible_files, @output = DeltaMaker.new(@avatar).run_test
    assert @visible_files.keys.include?('output')
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  test '925',
  'test():delta[:changed] files are changed' do
    kata = make_language_kata({
      'display_name' => default_language_name('stateful')
    })
    @avatar = kata.start_avatar
    code_filename = 'hiker.c'
    test_filename = 'hiker.tests.c'
    maker = DeltaMaker.new(@avatar)
    maker.change_file(code_filename, new_code = 'changed content for code file')
    maker.change_file(test_filename, new_test = 'changed content for test file')
    _, @visible_files, _ = maker.run_test
    assert_file code_filename, new_code
    assert_file test_filename, new_test
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  test '749',
  'test():delta[:unchanged] files are unchanged' do
    kata = make_language_kata({
      'display_name' => default_language_name('stateful')
    })
    @avatar = kata.start_avatar
    filename = 'hiker.c'
    assert @avatar.visible_filenames.include? filename
    content = @avatar.visible_files[filename]
    maker = DeltaMaker.new(@avatar)
    _, @visible_files, _ = maker.run_test
    assert_file filename, content
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  test '683',
  'test():delta[:new] files are created' do
    kata = make_language_kata
    @avatar = kata.start_avatar
    maker = DeltaMaker.new(@avatar)
    filename = 'new_file.c'
    content = 'once upon a time'
    maker.new_file(filename, content)
    _, @visible_files, _ = maker.run_test
    assert_file filename, content
  end

  private # - - - - - - - - - - - - - - - - - - - - - - -

  def assert_file(filename, expected)
    assert_equal(expected, @output) if filename == 'output'
    assert_equal expected, @visible_files[filename], 'returned_to_browser'
    assert_equal expected, @avatar.visible_files[filename], 'saved_to_manifest'
  end

end

