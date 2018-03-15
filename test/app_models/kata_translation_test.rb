require_relative 'app_models_test_base'

class KataTranslationTest < AppModelsTestBase

  def self.hex_prefix
    '6852C2'
  end

  def hex_setup
    # tests are for specific kata-ids tar-piped into storer
    set_storer_class('StorerService')
    set_starter_class('StarterService')
  end

  #- - - - - - - - - - - - - - - - - - - - - - - -

  test 'E2A',
  'new-style kata not involving renaming (dolphin, 20 lights)' do
    @kata_id = '420B05BA0A'
    manifest = storer.kata_manifest(@kata_id)
    expected_keys = %w(
      created id
      display_name exercise image_name runner_choice visible_files
      filename_extension highlight_filenames lowlight_filenames progress_regexs tab_size
    )
    assert_equal expected_keys.sort, manifest.keys.sort

    assert_id @kata_id
    assert_created '2017-10-25 13:31:50 +0000'
    assert_display_name 'Java, JUnit'
    assert_exercise '(Verbal)'
    assert_filename_extension '.java'
    assert_image_name 'cyberdojofoundation/java_junit'
    assert_max_seconds 10
    assert_runner_choice 'stateless'
    assert_tab_size 4
  end

  #- - - - - - - - - - - - - - - - - - - - - - - -

  test 'E2B',
  'new-style kata not involving renaming (snake, 0 lights)' do
    @kata_id = '420F2A2979'
    manifest = storer.kata_manifest(@kata_id)
    expected_keys = %w(
      created id
      display_name exercise image_name runner_choice visible_files
      filename_extension highlight_filenames lowlight_filenames progress_regexs tab_size
    )
    assert_equal expected_keys.sort, manifest.keys.sort

    assert_id @kata_id
    assert_created '2017-08-02 20:46:48 +0000'
    assert_display_name 'PHP, PHPUnit'
    assert_exercise 'Anagrams'
    assert_filename_extension('.php')
    assert_image_name 'cyberdojofoundation/php_phpunit'
    assert_max_seconds 10
    assert_runner_choice 'stateful'
    assert_tab_size 4
  end

  #- - - - - - - - - - - - - - - - - - - - - - - -

  test 'E2C',
  'old-style kata involving renaming (buffalo, 36 lights)' do
    @kata_id = '421F303E80'
    manifest = storer.kata_manifest(@kata_id)
    expected_keys = %w(
      created id exercise visible_files tab_size
      display_name image_name runner_choice
    )
    assert_equal expected_keys.sort, manifest.keys.sort

    assert_id @kata_id
    assert_created '2013-02-18 13:22:10 +0000'
    assert_display_name 'C (gcc), assert'
    assert_exercise 'Calc_Stats'
    #assert_filename_extension('.c')
    assert_image_name 'cyberdojofoundation/gcc_assert'
    assert_max_seconds 10
    assert_runner_choice 'stateless'
    assert_tab_size 4
  end

  #- - - - - - - - - - - - - - - - - - - - - - - -

  test 'E2D',
  'old-style kata involving renaming (wolf, 1 light)' do
    @kata_id = '421AFD7EC5'
    manifest = storer.kata_manifest(@kata_id)
    expected_keys = %w(
      created id exercise visible_files tab_size
      display_name image_name runner_choice
    )
    assert_equal expected_keys.sort, manifest.keys.sort

    assert_id @kata_id
    assert_created '2014-11-20 09:55:58 +0000'
    assert_exercise 'Poker_Hands'
    #assert_filename_extension '.rb'
    assert_max_seconds 10
    assert_tab_size 2
    assert_display_name 'Ruby, RSpec'
    assert_image_name 'cyberdojofoundation/ruby_rspec'
    assert_runner_choice 'stateless'
  end

  #- - - - - - - - - - - - - - - - - - - - - - - -

  test 'E2E',
  'old-style kata not involving renaming (hummingbird, 0 lights)' do
    @kata_id = '420BD5D5BE'
    manifest = storer.kata_manifest(@kata_id)
    expected_keys = %w(
      id created exercise visible_files tab_size
      display_name image_name runner_choice
    )
    assert_equal expected_keys.sort, manifest.keys.sort

    assert_id @kata_id
    assert_created '2016-08-01 22:54:33 +0000'
    assert_exercise 'Fizz_Buzz'
    #assert_filename_extension('.py')
    assert_max_seconds 10
    assert_tab_size 4
    assert_display_name 'Python, py.test'
    assert_image_name 'cyberdojofoundation/python_pytest'
    assert_runner_choice 'stateless'
  end

  #- - - - - - - - - - - - - - - - - - - - - - - -

  test 'E2F',
  'new-style kata not involving renaming (spider, 8 lights) with red_amber_green property' do
    @kata_id = '5A0F824303'
    manifest = storer.kata_manifest(@kata_id)
    expected_keys = %w(
      id created exercise visible_files progress_regexs tab_size
      filename_extension highlight_filenames lowlight_filenames
      display_name image_name runner_choice
    )
    assert_equal expected_keys.sort, manifest.keys.sort

    assert_id @kata_id
    assert_created '2016-11-23 08:34:28 +0000'
    assert_exercise 'Reversi'
    assert_filename_extension('.py')
    assert_max_seconds 10
    assert_tab_size 4
    assert_display_name 'Python, behave'
    assert_image_name 'cyberdojofoundation/python_behave'
    assert_runner_choice 'stateless'
  end

  private # = = = = = = = = = = = = = = = = = = =

  def assert_id(expected)
    assert_equal expected, kata.id, 'id'
  end

  def assert_created(expected)
    assert_equal expected, kata.created.to_s, 'created'
  end

  def assert_display_name(expected)
    assert_equal expected, kata.display_name, 'display_name'
  end

  def assert_exercise(expected)
    assert_equal expected, kata.exercise, 'exercise'
  end

  def assert_filename_extension(expected)
    assert_equal expected, kata.filename_extension, 'filename_extension'
  end

  def assert_image_name(expected)
    assert_equal expected, kata.image_name, 'image_name'
  end

  def assert_max_seconds(expected)
    assert_equal expected, kata.max_seconds, 'max_seconds'
  end

  def assert_runner_choice(expected)
    assert_equal expected, kata.runner_choice, 'runner_choice'
  end

  def assert_tab_size(expected)
    assert_equal expected, kata.tab_size, 'tab_size'
  end

  # - - - - - - - - - - - - - - - - - - - -

  def kata
    katas[@kata_id]
  end

end
