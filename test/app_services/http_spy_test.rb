require_relative 'app_services_test_base'

class HttpSpyTest < AppServicesTestBase

  def self.hex_prefix
    '951'
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  test '8D4',
  'after get() we can spy' do
    spy = HttpSpy.new(nil)
    spy.get('runner', 9556, 'avatar_new', { :name => 'salmon' })
    assert_equal [
      'runner', 9556, 'avatar_new', { :name => 'salmon' }
    ], spy.spied[0]
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  test '8D5',
  'after post() we can spy hostname and named_args' do
    spy = HttpSpy.new(nil)
    spy.post('runner', 9556, 'avatar_new', { :name => 'salmon' })
    assert_equal [
      'runner', 9556, 'avatar_new', { :name => 'salmon' }
    ], spy.spied[0]
  end

end
