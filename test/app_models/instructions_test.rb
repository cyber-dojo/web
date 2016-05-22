#!/bin/bash ../test_wrapper.sh

require_relative './app_models_test_base'

class InstructionsTest < AppModelsTestBase

  test '2DDD4C',
  'path has correct basic format when set with trailing slash' do
    path = tmp_root + '/' + 'folder'
    set_instructions_root(path + '/')
    assert_equal path, instructions.path
    assert correct_path_format?(instructions)
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  test '2DDC99',
  'path has correct basic format when set without trailing slash' do
    path = tmp_root + '/' + 'folder'
    set_instructions_root(path)
    assert_equal path, instructions.path
    assert correct_path_format?(instructions)
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  test '2DD327',
  '[name] is nil if name is not an existing instructions' do
    assert_nil instructions['wibble_XXX']
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  test '2DDD85',
  'exercise path has correct basic format' do
    fizz_buzz = instructions['Fizz_Buzz']
    assert fizz_buzz.path.match(fizz_buzz.name)
    assert correct_path_format?(fizz_buzz)
  end

  #- - - - - - - - - - - - - - - - - - - - - -

  test '2DDEF3',
  'name is as set in creation' do
    fizz_buzz = instructions[name = 'Fizz_Buzz']
    assert_equal name, fizz_buzz.name
  end

  #- - - - - - - - - - - - - - - - - - - - - -

  test '2DD65F',
  'instructions are loaded from file of same name via the cache' do
    fizz_buzz = instructions['Fizz_Buzz']
    assert fizz_buzz.text.start_with? 'Write a program that prints'
  end

  #- - - - - - - - - - - - - - - - - - - - - -

  test '2DD280',
  'instructions are loaded from file of same name directly' do
    fizz_buzz = Instruction.new(dojo.instructions, 'Fizz_Buzz')
    assert fizz_buzz.text.start_with? 'Write a program that prints'
  end

  #- - - - - - - - - - - - - - - - - - - - - -

  test '2DD64B',
  'cache is created on demand' do
    # be very careful here... naming instructions will create instructions!
    path = instructions.cache_path
    filename = instructions.cache_filename
    assert disk[path].exists? filename
    old_cache = disk[path].read(filename)
    `rm #{path}/#{filename}`
    refute disk[path].exists? filename
    @dojo = nil  # force dojo.instructions to be new Instructions object
    instructions    # dojo.instructions ||= Instructions.new(...)
    assert disk[path].exists? filename
    new_cache = disk[path].read(filename)
    assert_equal old_cache, new_cache
  end

  #- - - - - - - - - - - - - - - - - - - - - -

  test '2DD958',
  'simple smoke test' do
    instructions_names = instructions.map(&:name).sort
    doors = '100_doors'
    assert instructions_names.size > 20
    assert instructions_names.include?(doors)
    assert instructions['100_doors'].text.start_with?('100 doors in a row')
  end

end
