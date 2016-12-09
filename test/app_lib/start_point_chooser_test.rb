#!/bin/bash ../test_wrapper.sh

require_relative './app_lib_test_base'

class StartPointChooserTest < AppLibTestBase

  include StartPointChooser

  def setup
    super
    set_storer_class('FakeStorer')
    set_runner_class('NotUsed')
    set_differ_class('NotUsed')
  end

  #- - - - - - - - - - - - - - - - - - - - - - -

  test '773616',
  'when id is given and katas[id].language exists then choose that language' do
    cmd = test_languages_names.map{ |name| name.split('-').join(', ') }
    test_languages_names.each_with_index do |language, n|
      id = make_kata({ language:language, exercise:test_exercises_names.sample }).id
      assert_equal n, choose_language(cmd, katas[id]), language
    end
  end

  #- - - - - - - - - - - - - - - - - - - - - - -

  test 'D9C2F2',
  'when id is given and katas[id].exercise exists then choose that exercise' do
    test_exercises_names.each_with_index do |exercise, n|
      id = make_kata({ language:test_languages_names.sample, exercise:exercise }).id
      assert_equal n, choose_exercise(test_exercises_names, katas[id])
    end
  end

  #- - - - - - - - - - - - - - - - - - - - - - -

  test 'CD36CB',
  'when no id is given then choose random language/exercise' do
    assert_is_randomly_chosen_language(test_languages_names, kata = nil)
    assert_is_randomly_chosen_exercise(test_exercises_names, kata = nil)
  end

  #- - - - - - - - - - - - - - - - - - - - - - -

  test '64576B',
  'when chooser is passed choices=[] and kata=nil result is nil' do
    assert_nil choose_language(choices=[], kata=nil)
    assert_nil choose_exercise(choices=[], kata=nil)
  end

  #- - - - - - - - - - - - - - - - - - - - - - -

  test '9671E1',
  'when id is given and katas[id] language does not exist then choose random language' do
    test_languages_names.each do |unknown_language|
      languages = test_languages_names - [unknown_language]
      refute languages.include?(unknown_language)
      id = make_kata({ language:unknown_language, exercise:test_exercises_names.sample }).id
      assert_is_randomly_chosen_language(languages, katas[id])
    end
  end

  #- - - - - - - - - - - - - - - - - - - - - - -

  test '8D0F94',
  'when id is given and katas[id] exercise does not exist then choose random instructions' do
    test_exercises_names.each do |unknown_exercise|
      exercises = test_exercises_names - [unknown_exercise]
      refute exercises.include?(unknown_exercise)
      id = make_kata({ language:test_languages_names.sample, exercise:unknown_exercise }).id
      assert_is_randomly_chosen_exercise(exercises, katas[id])
    end
  end

  #- - - - - - - - - - - - - - - - - - - - - - -

  private

  def assert_is_randomly_chosen_language(languages, kata)
    counts = {}
    (1..100).each do
      n = choose_language(languages, kata)
      counts[n] ||= 0
      counts[n] += 1
    end
    assert_equal languages.length, counts.length
  end

  #- - - - - - - - - - - - - - - - - - - - - - -

  def assert_is_randomly_chosen_exercise(exercises, kata)
    counts = {}
    (1..100).each do
      n = choose_exercise(exercises, kata)
      counts[n] ||= 0
      counts[n] += 1
    end
    assert_equal exercises.length, counts.length
  end

  #- - - - - - - - - - - - - - - - - - - - - - -

  def test_languages_names
    [ 'C#-NUnit',
      'C++ (g++)-GoogleTest',
      'Ruby-Test::Unit',
      'Java-JUnit'
    ].sort

  end

  #- - - - - - - - - - - - - - - - - - - - - - -

  def test_exercises_names
    ['Yatzy',
     'Roman_Numerals',
     'Leap_Years',
     'Fizz_Buzz',
     'Zeckendorf_Number'
    ].sort
  end

end
