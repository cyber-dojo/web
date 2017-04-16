require_relative 'lib_test_base'

class HttpSpyTest < LibTestBase

  test '9518D4',
  'after get() we can spy hostname and named_args' do
    spy = HttpSpy.new(nil)
    spy.get('runner', 9556, 'avatar_new', { :name => 'salmon' })
    assert spy.spied_hostname? 'runner'
    refute spy.spied_hostname? 'wibble'
    assert spy.spied_named_arg? :name
    refute spy.spied_named_arg? :image_name
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  test '9518D5',
  'after post() we can spy hostname and named_args' do
    spy = HttpSpy.new(nil)
    spy.post('runner', 9556, 'avatar_new', { :name => 'salmon' })
    assert spy.spied_hostname? 'runner'
    refute spy.spied_hostname? 'wibble'
    assert spy.spied_named_arg? :name
    refute spy.spied_named_arg? :image_name
  end

end
