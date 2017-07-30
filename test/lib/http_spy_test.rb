require_relative 'lib_test_base'

class HttpSpyTest < LibTestBase

  test '9518D4',
  'after get() we can spy' do
    spy = HttpSpy.new(nil)
    spy.get('runner', 9556, 'avatar_new', { :name => 'salmon' })
    assert_equal [
      'runner', 9556, 'avatar_new', { :name => 'salmon' }
    ], spy.spied[0]
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  test '9518D5',
  'after post() we can spy hostname and named_args' do
    spy = HttpSpy.new(nil)
    spy.post('runner', 9556, 'avatar_new', { :name => 'salmon' })
    assert_equal [
      'runner', 9556, 'avatar_new', { :name => 'salmon' }
    ], spy.spied[0]
  end

end
