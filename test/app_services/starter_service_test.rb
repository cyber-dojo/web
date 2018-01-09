require_relative 'app_services_test_base'

class StarterServiceTest < AppServicesTestBase

  def self.hex_prefix
    'D76AD9'
  end

  def hex_setup
    set_differ_class('NotUsed')
    set_starter_class('StarterService')
    set_storer_class('NotUsed')
    set_runner_class('NotUsed')
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - -

  test '3AA',
  'smoke test' do
    json = starter.custom_choices
    assert_equal [ 'Yahtzee refactoring' ], json['major_names']
    assert_equal [
      'C# NUnit',
      'C++ (g++) assert',
      'Java JUnit',
      'Python unitttest'
    ], json['minor_names']
    assert_equal [[0,1,2,3]], json['minor_indexes']

    json = starter.languages_choices
    assert_equal [
      'C (gcc)',
      'C++ (g++)',
      'Python',
      'Ruby'
    ], json['major_names']
    assert_equal [
      'MiniTest',
      'RSpec',
      'Test::Unit',
      'assert',
      'behave',
      'py.test',
      'unittest'
    ], json['minor_names']
    assert_equal [[3],[3],[4,5,6],[0,1,2]], json['minor_indexes']

    json = starter.exercises_choices
    assert_equal [
      'Bowling_Game',
      'Fizz_Buzz',
      'Leap_Years',
      'Tiny_Maze'
    ], json['names']

    manifest = starter.custom_manifest('Yahtzee refactoring', 'C# NUnit')
    assert_equal 'Yahtzee refactoring, C# NUnit', manifest['display_name']

    manifest = starter.language_manifest('Ruby', 'MiniTest', 'Fizz_Buzz')
    assert_equal 'Ruby, MiniTest', manifest['display_name']

    manifest = starter.manifest('C')
    assert_equal 'C (gcc), assert', manifest['display_name']
  end

end