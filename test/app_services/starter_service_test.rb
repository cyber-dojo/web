require_relative 'app_services_test_base'

class StarterServiceTest < AppServicesTestBase

  def self.hex_prefix
    'D76'
  end

  def hex_setup
    set_differ_class('NotUsed')
    set_starter_class('StarterService')
    set_storer_class('NotUsed')
    set_runner_class('NotUsed')
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - -

  test '3A9',
  'smoke test starter.sha' do
    assert_sha starter.sha
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - -

  test '3AA',
  'language_start_points' do
    start_points = starter.language_start_points
    assert_equal [
      'C (gcc), assert',
      'C++ (g++), assert',
      'Java, JUnit',
      'Python, behave',
      'Python, py.test',
      'Ruby, MiniTest',
      'Ruby, RSpec',
      'Ruby, Test::Unit'
    ], start_points['languages']

    exercises = start_points['exercises']
    assert_equal [
      'Bowling_Game',
      'Fizz_Buzz',
      'Leap_Years',
      'Tiny_Maze'
    ], exercises.keys.sort

    line = 'Write a program to score a game of Ten-Pin Bowling'
    assert exercises['Bowling_Game'].start_with? line

    line = 'Write a program that prints the numbers from 1 to 100'
    assert exercises['Fizz_Buzz'].start_with? line

    line = 'Write a function that returns true or false depending on'
    assert exercises['Leap_Years'].start_with? line

    line = 'Alice found herself very tiny and wandering around Wonderland'
    assert exercises['Tiny_Maze'].start_with? line
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - -

  test '3AB',
  'language_manifest' do
    manifest = starter.language_manifest('Ruby, MiniTest', 'Fizz_Buzz')
    assert_equal 'Ruby, MiniTest', manifest['display_name']
    assert_equal 'cyberdojofoundation/ruby_mini_test', manifest['image_name']
    assert_equal '.rb', manifest['filename_extension']
    assert_equal 2, manifest['tab_size']
    assert_equal 'stateless', manifest['runner_choice']
    assert_equal 'Fizz_Buzz', manifest['exercise']
    assert_equal %w(
      coverage.rb
      test_hiker.rb
      hiker.rb
      cyber-dojo.sh
      output
      instructions
    ).sort, manifest['visible_files'].keys.sort
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - -

  test '3AC',
  'custom_start_points' do
    assert_equal [
      'Yahtzee refactoring, C# NUnit',
      'Yahtzee refactoring, C++ (g++) assert',
      'Yahtzee refactoring, Java JUnit',
      'Yahtzee refactoring, Python unitttest'
    ], starter.custom_start_points
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - -

  test '3AD',
  'custom_manifest' do
    manifest = starter.custom_manifest('Yahtzee refactoring, C# NUnit')
    assert_equal 'Yahtzee refactoring, C# NUnit', manifest['display_name']
    assert_equal 'cyberdojofoundation/csharp_nunit', manifest['image_name']
    assert_equal '.cs', manifest['filename_extension']
    assert_equal 'stateless', manifest['runner_choice']
    assert_equal %w(
      YahtzeeTest.cs
      Yahtzee.cs
      cyber-dojo.sh
      output
      instructions
    ).sort, manifest['visible_files'].keys.sort
  end

end
