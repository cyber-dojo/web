require_relative 'app_services_test_base'

class DifferServiceTest < AppServicesTestBase

  def self.hex_prefix
    '702922'
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - -

  test '3AB',
  'smoke test' do
    in_kata(:stateless) {
      as(:wolf) {
        args = []
        args << kata.id
        args << wolf.name
        args << wolf.visible_files
        args << (now = [2016,12,8, 8,3,23])
        args << (stdout = "Expected: 42\nActual: 54")
        args << (stderr = 'assertion failed')
        args << (colour = 'red')
        storer.avatar_ran_tests(*args)

        actual = differ.diff(kata.id, wolf.name, was_tag=0, now_tag=1)

        filename = 'hiker.rb'
        refute_nil actual[filename]
        assert_equal({
          'type'   => 'same',
          'line'   => 'def answer',
          'number' => 1
        }, actual[filename][0])

        assert_equal({
          'type'   => 'same',
          'line'   => '  6 * 9',
          'number' => 2
        }, actual[filename][1])
      }
    }
  end

end
