require_relative 'app_services_test_base'
require_relative 'http_json_requester_not_json_stub'
require_relative '../../app/services/exercises_start_points_service'

class ExercisesStartPointsServiceTest < AppServicesTestBase

  def self.hex_prefix
    'A83'
  end

  def hex_setup
    set_exercises_start_points_class('ExercisesStartPointsService')
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - -

  test '3A7',
  'response.body failure is mapped to exception' do
    set_http(HttpJsonRequesterNotJsonStub)
    error = assert_raises(ExercisesStartPointsService::Error) { exercises_start_points.ready? }
    assert error.message.start_with?('http response.body is not JSON'), error.message
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - -

  test '3A9',
  'smoke test ready?' do
    assert exercises_start_points.ready?
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - -

  test '3AC',
  'smoke test names' do
    assert_equal expected_names.sort, exercises_start_points.names
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - -

  test '3AF',
  'smoke test manifests' do
    manifests = exercises_start_points.manifests
    assert manifests.is_a?(Hash)
    assert_equal expected_names.sort, manifests.keys.sort
    manifest = manifests['Gray Code']
    assert_is_Gray_Code_manifest(manifest)
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - -

  test '3AD',
  'smoke test manifest(name)' do
    manifest = exercises_start_points.manifest('Gray Code')
    assert_is_Gray_Code_manifest(manifest)
  end

  private

  def expected_names
    [
      "(Verbal)", "100 doors", "Anagrams", "Array Shuffle",
      "Balanced Parentheses", "Bowling Game", "Calc Stats", "Closest To Zero",
      "Combined Number", "Count Coins", "Diversion", "Eight Queens",
      "Fizz Buzz", "Fizz Buzz Plus", "Friday 13th", "Game of Life", "Gray Code",
      "Haiku Review", "Harry Potter", "ISBN", "LCD Digits", "Leap Years",
      "Magic Square", "Mars Rover", "Mine Field", "Mine Sweeper", "Monty Hall",
      "Number Chains", "Number Names", "Phone Numbers", "Poker Hands", "Prime Factors", 
      "Print Diamond", "Recently Used List", "Remove Duplicates", "Reordering",
      "Reverse Roman", "Reversi", "Roman Numerals", "Saddle Points",
      "Tennis", "Tiny Maze", "Unsplice", "Wonderland Number", "Word Wrap",
      "Yatzy", "Yatzy Cutdown", "Zeckendorf Number"
    ]
  end

  def assert_is_Gray_Code_manifest(manifest)
    expected_keys = %w( display_name visible_files )
    assert_equal expected_keys.sort, manifest.keys.sort

    assert_equal 'Gray Code', manifest['display_name']
    expected_filenames = %w( readme.txt )
    visible_files = manifest['visible_files']
    assert_equal expected_filenames, visible_files.keys.sort
    assert_starts_with(visible_files, 'readme.txt', 'Create functions to')
  end

end
