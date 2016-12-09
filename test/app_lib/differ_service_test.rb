#!/bin/bash ../test_wrapper.sh

require_relative './app_lib_test_base'

class DifferServiceTest < AppLibTestBase

  def setup
    super
    set_storer_class('FakeStorer')
    set_runner_class('StubRunner')
  end

  #------------------------------------------------------------------

  test '9823AB',
  'smoke test differ-service' do
    kata = make_kata
    kata.start_avatar([lion])

    args = []
    args << kata.id
    args << lion
    files1 = starting_files
    delta = empty_delta
    delta['unchanged'] = files1.keys
    args << delta
    args << files1
    args << (now1 = [2016,12,8,8,3,23])
    args << (output = 'Assert failed: answer() == 42')
    args << (colour1 = 'red')
    storer.avatar_ran_tests(*args)

    actual = differ.diff(kata.avatars[lion], was_tag=0, now_tag=1)

  end

  private

  def lion; 'lion'; end

  def starting_files
    {
      'hiker.h'       => '#ifndef HIKER_INCLUDED...',
      'hiker.c'       => '#include "hiker.h"...',
      'hiker.tests.c' => '#include <assert.h>...',
      'cyber-dojo.sh' => 'make --always-make',
      'instructions'  => 'FizzBuzz is a game...'
    }.clone
  end

  def empty_delta
    { 'unchanged' => [], 'changed' => [], 'new' => [], 'deleted' => [] }
  end

end
