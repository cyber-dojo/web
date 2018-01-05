require_relative 'app_services_test_base'

class DifferServiceTest < AppServicesTestBase

  def self.hex_prefix
    '702922'
  end

  def hex_setup
    set_differ_class('DifferService')
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - -

  test '3AB',
  'smoke test' do
    kata = make_language_kata({ 'display_name' => 'C (gcc), assert' })
    avatar = kata.start_avatar
    begin
      args = []
      args << kata.id
      args << avatar.name
      args << avatar.visible_files
      args << (now = [2016,12,8, 8,3,23])
      args << (output = 'Assert failed: answer() == 42')
      args << (colour = 'red')
      storer.avatar_ran_tests(*args)

      actual = differ.diff(kata.id, avatar.name, was_tag=0, now_tag=1)

      refute_nil actual['hiker.c']
      assert_equal({
        'type'   => 'same',
        'line'   => '#include "hiker.h"',
        'number' => 1
      }, actual['hiker.c'][0])
    ensure
      runner.avatar_old(kata.image_name, kata.id, avatar.name)
      runner.kata_old(kata.image_name, kata.id)
    end
  end

end
