require_relative 'app_services_test_base'

class DifferServiceTest < AppServicesTestBase

  def self.hex_prefix
    '702922'
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - -

  test '3AB',
  'smoke test' do
    in_kata(:stateful) {
      as(:wolf) {
        args = []
        args << kata.id
        args << wolf.name
        args << wolf.visible_files
        args << (now = [2016,12,8, 8,3,23])
        args << (output = 'Assert failed: answer() == 42')
        args << (colour = 'red')
        storer.avatar_ran_tests(*args)

        actual = differ.diff(kata.id, wolf.name, was_tag=0, now_tag=1)

        refute_nil actual['hiker.c']
        assert_equal({
          'type'   => 'same',
          'line'   => '#include "hiker.h"',
          'number' => 1
        }, actual['hiker.c'][0])
      }
    }
  end

end
