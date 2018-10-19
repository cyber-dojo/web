require_relative 'app_services_test_base'

class DifferServiceTest < AppServicesTestBase

  def self.hex_prefix
    '702922'
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - -

  test '3AA',
  'smoke test differ.sha' do
    assert_sha differ.sha
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - -

  test '3AB',
  'smoke test differ.diff(..., was_tag=0, now_tag=1)' do
    in_kata(:stateless) { |kata|
      args = []
      args << (n = 1)
      args << kata.files
      args << (now = [2016,12,8, 8,3,23])
      args << (stdout = "Expected: 42\nActual: 54")
      args << (stderr = 'assertion failed')
      args << (status = 0)
      args << (colour = 'red')
      kata.ran_tests(*args)

      actual = differ.diff(kata.id, was_tag=0, now_tag=1)

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
  end

end
