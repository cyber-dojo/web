require_relative 'app_models_test_base'

class KataForkTest < AppModelsTestBase

  def self.hex_prefix
    '3F2BE5'
  end

  def hex_setup
    set_storer_class('StorerService')
    # tests are for specific kata-ids tar-piped into storer
  end

  #- - - - - - - - - - - - - - - - - - - - - - - -

  test 'DB0', %w(
  forking an old-old kata with a 'unit_test_framework' property
  undergoes starter-translation ) do
    forked = katas['421F303E80'].fork({ 'cyber-dojo.sh' => 'cd' })
    @kata_id = forked['id']
    forked_expected_keys = %w(
      created id
      display_name exercise image_name runner_choice visible_files
      filename_extension
    )
    assert_equal forked_expected_keys.sort, forked.keys.sort

    assert_id @kata_id
    assert_display_name 'C (gcc), assert'
    assert_exercise 'Calc_Stats'
    assert_filename_extension('.c')
    assert_image_name 'cyberdojofoundation/gcc_assert'
    assert_runner_choice 'stateful'
    assert_visible_files({ 'cyber-dojo.sh' => 'cd' })
  end

  #- - - - - - - - - - - - - - - - - - - - - - - -

  test 'DB1', %w(
  forking an old-old kata with a 'unit_test_framework' property,
  undergoes starter-translation ) do
    forked = katas['421AFD7EC5'].fork({ 'cyber-dojo.sh' => 'ls -al' })
    @kata_id = forked['id']
    forked_expected_keys = %w(
      created id
      display_name exercise image_name runner_choice visible_files
      tab_size filename_extension
    )
    assert_equal forked_expected_keys.sort, forked.keys.sort

    assert_id @kata_id
    assert_display_name 'Ruby, RSpec' # capital S
    assert_exercise 'Poker_Hands'
    assert_filename_extension '.rb'
    assert_image_name 'cyberdojofoundation/ruby_rspec'
    assert_runner_choice 'stateless'
    assert_tab_size 2 # explicit
    assert_visible_files({ 'cyber-dojo.sh' => 'ls -al' })
  end

  #- - - - - - - - - - - - - - - - - - - - - - - -

  test 'DB2', %w(
  forking a old kata that does not have a 'runner_choice' property
  undergoes starter-translation ) do
    forked = katas['5A0F824303'].fork({ 'cyber-dojo.sh' => 'addgroup' })
    @kata_id = forked['id']
    forked_expected_keys = %w(
      id created
      display_name exercise image_name runner_choice visible_files
      filename_extension highlight_filenames lowlight_filenames progress_regexs tab_size
      language red_amber_green
    )
    assert_equal forked_expected_keys.sort, forked.keys.sort
    assert_equal 'Python-behave', forked['language']

    assert_id @kata_id
    assert_display_name 'Python, behave'
    assert_exercise 'Reversi'
    assert_filename_extension('.py')
    assert_image_name 'cyberdojofoundation/python_behave'
    assert_max_seconds 10
    assert_runner_choice 'stateless'
    assert_tab_size 4
  end

  #- - - - - - - - - - - - - - - - - - - - - - - -

  test 'DB3', %w(
  forking a new-style kata does not undergo starter-translation ) do
    forked = katas['420B05BA0A'].fork({ 'cyber-dojo.sh' => 'pwd' })
    @kata_id = forked['id']

    forked_expected_keys = %w(
      created id
      display_name exercise image_name runner_choice visible_files
      filename_extension highlight_filenames lowlight_filenames progress_regexs tab_size
      language
    )
    assert_equal forked_expected_keys.sort, forked.keys.sort
    assert_equal 'Java-JUnit', forked['language']

    assert_id @kata_id
    assert_display_name 'Java, JUnit'
    assert_exercise '(Verbal)'
    assert_filename_extension '.java'
    assert_image_name 'cyberdojofoundation/java_junit'
    assert_max_seconds 10
    assert_runner_choice 'stateless'
    assert_tab_size 4
    assert_visible_files({ 'cyber-dojo.sh' => 'pwd' })
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

  def assert_visible_files(expected)
    assert_equal expected, kata.visible_files, 'visible_files'
  end

  # - - - - - - - - - - - - - - - - - - - -

  def kata
    katas[@kata_id]
  end

end
