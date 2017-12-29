require_relative 'app_services_test_base'

class DifferServiceTest < AppServicesTestBase

  def self.hex_prefix
    '702922'
  end

  def hex_setup
    set_differ_class('DifferService')
    set_storer_class('StorerFake')
    set_runner_class('RunnerService') # TODO decouple
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - -

  test '3AB',
  'smoke test' do
    kata = make_language_kata({
      'display_name' => default_language_name('stateful')
    })
    kata.start_avatar([lion])
    begin
      args = []
      args << kata.id
      args << lion
      args << (files1 = starting_files)
      args << (now1 = [2016,12,8, 8,3,23])
      args << (output = 'Assert failed: answer() == 42')
      args << (colour = 'red')
      storer.avatar_ran_tests(*args)
      actual = differ.diff(kata.id, lion, was_tag=0, now_tag=1)

      refute_nil actual['hiker.c']
      assert_equal({
        "type"=>"same", "line"=>"#include \"hiker.h\"", "number"=>1
      }, actual['hiker.c'][0])
    ensure
      runner.avatar_old(kata.image_name, kata.id, lion)
      runner.kata_old(kata.image_name, kata.id)
    end
  end

end
