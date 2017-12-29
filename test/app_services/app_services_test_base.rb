require_relative '../all'

class AppServicesTestBase < TestBase

  def creation_time
    [ 2016,12,5, 17,44,23 ]
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - -

  def tag0
    {
      'event'  => 'created',
      'time'   => creation_time,
      'number' => 0
    }
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - -

  def all_ids
    ids = []
    (0..255).map{|n| '%02X' % n}.each do |outer|
      storer.completions(outer).each do |inner|
        ids << (outer + inner)
      end
    end
    ids
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - -

  def starting_files
    {
      'hiker.h'       => [
        '#ifndef HIKER_INCLUDED',
        '#define HIKER_INCLUDED',
        'int answer(void);',
        '#endif'
      ].join("\n"),

      'hiker.c'       => [
        '#include "hiker.h"',
        'int answer(void) {',
        '    return 6 * 9;',
        '}'
      ].join("\n"),

      'hiker.tests.c' => [
        '#include "hiker.h"',
        '#include <assert.h>',
        '#include <stdio.h>',
        'static void life_the_universe_and_everything(void) {',
        '    assert(answer() == 42);',
        '}',
        'int main(void) {',
        '    life_the_universe_and_everything();',
        '    puts("All tests passed");',
        '}'
      ].join("\n"),

      'makefile'      => [
        'C_FILES = $(wildcard *.c)',
        '.PHONY: test.output',
        'test.output: test makefile',
        "\t@./$<",
        'test: makefile $(C_FILES)',
        "\t@gcc $(C_FILES) -o $@"
      ].join("\n"),

      'cyber-dojo.sh' => 'make --always-make',

      'instructions'  => 'FizzBuzz is a game...'
    }.clone
  end

end
