require_relative 'app_services_test_base'

class HttpSpyTest < AppServicesTestBase

  def self.hex_prefix
    '951'
  end

  def hex_setup
    @spy = HttpSpy.new(nil)
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  test '8D4',
  'after get() we can spy hostname, port, method-name, and named-args' do
    @spy.get('porter', 8116, 'port', { :id => '765uP43xFG' })
    assert_equal [
      'porter', 8116, 'port', { :id => '765uP43xFG' }
    ], @spy.spied[0]
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  test '8D5',
  'after post() we can spy hostname, port, method-name, and named_args' do
    @spy.post('saver', 9556, 'group_exists?', { :id => 'c76weH' })
    assert_equal [
      'saver', 9556, 'group_exists?', { :id => 'c76weH' }
    ], @spy.spied[0]
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  test '8D6',
  'before get() we can stub the response' do
    @spy.stub({ 'question' => '6*9' })
    response = @spy.get(service_name,port,method_name,named_args)
    assert_equal({ method_name => { 'question' => '6*9' }}, response)
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  test '8D7',
  'before post() we can stub the response' do
    @spy.stub({ 'answer' => 42 })
    response = @spy.post(service_name,port,method_name,named_args)
    assert_equal({ method_name => { 'answer' => 42 }}, response)
  end

  private

  def service_name
    'wibble'
  end

  def port
    1234
  end

  def method_name
    'fubar'
  end

  def named_args
    { 'dee' => '999', 'dum' => '911' }
  end

end
