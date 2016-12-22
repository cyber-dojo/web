require_relative './app_lib_test_base'

class DifferServiceTest < AppLibTestBase

  def setup
    super
    set_storer_class('FakeStorer')
    set_runner_class('StubRunner')
  end

  # - - - - - - - - - - - - - - - - - - - - - - -

  test '98205F',
  'bad arguments raises exception' do
    error = assert_raises(StandardError) {
      differ.raw_diff(nil, nil)
    }
    assert error.message.start_with?('DifferService:diff')
  end

  # - - - - - - - - - - - - - - - - - - - - - - -

  test '9823AB',
  'smoke test differ-service' do
    kata = make_kata
    kata.start_avatar([lion])
    args = []
    args << kata.id
    args << lion
    args << (files1 = starting_files)
    args << (now1 = [2016,12,8,8,3,23])
    args << (output = 'Assert failed: answer() == 42')
    args << (colour1 = 'red')
    storer.avatar_ran_tests(*args)
    actual = differ.diff(kata.id, lion, was_tag=0, now_tag=1)

    refute_nil actual['hiker.c']
    assert_equal({
      "type"=>"same", "line"=>"#include \"hiker.h\"", "number"=>1
    }, actual['hiker.c'][0])

  end

end
