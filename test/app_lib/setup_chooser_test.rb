#!/bin/bash ../test_wrapper.sh

require_relative './app_lib_test_base'

class SetupChooserTest < AppLibTestBase

  include SetupChooser

  def setup
    super
    set_katas_root(tmp_root + 'katas')
  end

  #- - - - - - - - - - - - - - - - - - - - - - -

  test '773616',
  'when id is given and katas[id].language exists then choose that language' do
    cmd = test_languages_names.map{ |name| name.split('-').join(', ') }
    test_languages_names.each_with_index do |language, n|
      kata = make_kata({ language:language, exercise:test_instructions_names.sample })
      assert_equal n, choose_language(cmd, kata.id, katas), language
    end
  end

  #- - - - - - - - - - - - - - - - - - - - - - -

  test 'D9C2F2',
  'when id is given and katas[id].exercise exists then choose that exercise' do
    test_instructions_names.each_with_index do |instruction, n|
      kata = make_kata({ language:test_languages_names.sample, exercise:instruction })
      assert_equal n, choose_instructions(test_instructions_names, kata.id, katas)
    end
  end

  #- - - - - - - - - - - - - - - - - - - - - - -

  test 'CD36CB',
  'when no id is given then choose random language' do
    assert_is_randomly_chosen_language(test_languages_names, id = nil, katas)
  end

  test '64576B',
  'when chooser is passed choices=[] and id=nil result is nil' do
    assert_nil choose_language([], nil, katas)
  end

  #- - - - - - - - - - - - - - - - - - - - - - -

  test '42D488',
  'when no id is given then choose random instructions' do
    assert_is_randomly_chosen_instructions(test_instructions_names, id = nil, katas)
  end

  #- - - - - - - - - - - - - - - - - - - - - - -

  test '41EB67',
  'when id is given but katas[id].nil? then choose random language' do
    id = unique_id
    kata = dojo.katas[id]
    assert_nil kata
    assert_is_randomly_chosen_language(test_languages_names, id, katas)
  end

  #- - - - - - - - - - - - - - - - - - - - - - -

  test '35A56C',
  'when id is given but katas[id].nil? then choose random instructions' do
    id = unique_id
    kata = dojo.katas[id]
    assert_nil kata
    assert_is_randomly_chosen_instructions(test_instructions_names, id, katas)
  end

  #- - - - - - - - - - - - - - - - - - - - - - -

  test '9671E1',
  'when id is given and _!_katas[id].language.exists? then choose random language' do
    test_languages_names.each do |unknown_language|
      languages = test_languages_names - [unknown_language]
      refute languages.include?(unknown_language)
      kata = make_kata({ language:unknown_language, exercise:test_instructions_names.sample })
      assert_is_randomly_chosen_language(languages, kata.id, katas)
    end
  end

  #- - - - - - - - - - - - - - - - - - - - - - -

  test '8D0F94',
  'when id is given and _!_katas[id].instructions.exists? then choose random instructions' do
    test_instructions_names.each do |unknown_instruction|
      instructions = test_instructions_names - [unknown_instruction]
      refute instructions.include?(unknown_instruction)
      kata = make_kata({ language:test_languages_names.sample, exercise:unknown_instruction })
      assert_is_randomly_chosen_instructions(instructions, kata.id, katas)
    end
  end

  #- - - - - - - - - - - - - - - - - - - - - - -

  private

  def assert_is_randomly_chosen_language(languages, id, katas)
    counts = {}
    (1..100).each do
      n = choose_language(languages, id, katas)
      counts[n] ||= 0
      counts[n] += 1
    end
    assert_equal languages.length, counts.length
  end

  #- - - - - - - - - - - - - - - - - - - - - - -

  def assert_is_randomly_chosen_instructions(instructions, id, katas)
    counts = {}
    (1..100).each do
      n = choose_instructions(instructions, id, katas)
      counts[n] ||= 0
      counts[n] += 1
    end
    assert_equal instructions.length, counts.length
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

  def test_instructions_names
    ['Yatzy',
     'Roman_Numerals',
     'Leap_Years',
     'Fizz_Buzz',
     'Zeckendorf_Number'
    ].sort
  end

end
