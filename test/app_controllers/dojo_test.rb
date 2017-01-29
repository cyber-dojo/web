require_relative 'app_controller_test_base'

class DojoControllerTest < AppControllerTestBase

  def setup_runner_class
    set_runner_class('StubRunner')
  end

  test '103BF7',
  'index without id' do
    set_storer_class('FakeStorer')
    get 'dojo/index'
    assert_response :success
  end

  #- - - - - - - - - - - - - - - -

  test '103957',
  'index with id' do
    set_storer_class('FakeStorer')
    get 'dojo/index', id:'1234512345'
    assert_response :success
  end

  #- - - - - - - - - - - - - - - -

  test '10378E',
  'check_id exists=false when no kata for id' do
    set_storer_class('FakeStorer')
    @id = 'abcdef'
    check_id
  end

  #- - - - - - - - - - - - - - - -

  test '10390C',
  'check_id exists=true when id.length ~ 6 and kata exists' do
    set_storer_class('FakeStorer')
    [5,6,7].each do |n|
      create_kata
      @id = @id[0..(n-1)]
      assert_equal n, @id.length
      check_id
      refute empty?
      refute full?
    end
  end

  #- - - - - - - - - - - - - - - -

  test '1038EE',
  'show start/resume programming, with no id' do
    get '/enter/show'
  end

  test '103E3E',
  'show start/resume programming, with an id' do
    set_storer_class('FakeStorer')
    create_kata
    get '/enter/show', { :id => @id }
  end

  #- - - - - - - - - - - - - - - -

  test '103C5A',
  'show dashboard/review, with no id' do
    get '/enter/review'
  end

  test '103B19',
  'show dashboard/review, with an id' do
    set_storer_class('FakeStorer')
    create_kata
    get '/enter/review', { :id => @id }
  end

  #- - - - - - - - - - - - - - - -

  test '103F15',
  'start with no id raises' do
    assert_raises { start }
  end

  #- - - - - - - - - - - - - - - -

  test '103B84',
  'start with empty string id raises' do
    @id = ''
    assert_raises { start }
  end

  #- - - - - - - - - - - - - - - -

  test '103A79',
  'start with id that does not exist raises' do
    @id = 'ab00ab11ab'
    assert_raise { start }
  end

  #- - - - - - - - - - - - - - - -

  test '103BEE',
  'enter with id that does exist => !full,avatar_name' do
    set_storer_class('FakeStorer')
    create_kata
    start
    refute empty?
    refute full?
    assert Avatars.names.include?(@avatar.name)
  end

  #- - - - - - - - - - - - - - - -

  test '1032AE',
  'enter succeeds once for each avatar name, then dojo is full' do
    set_storer_class('FakeStorer')
    create_kata
    Avatars.names.each do |avatar_name|
      start
      refute full?
      assert Avatars.names.include? json['avatar_name']
      assert_not_nil @avatar.name
    end
    start_full
    refute empty?
    assert full?
    assert_equal '', json['avatar_name']
  end

  #- - - - - - - - - - - - - - - -

  test '1035BD',
  'continue with id that exists but is empty' do
    set_storer_class('FakeStorer')
    create_kata
    continue
    assert empty?
    refute full?
  end

  #- - - - - - - - - - - - - - - -

  test '103DEB',
  'continue with id that exists and is not empty' do
    set_storer_class('FakeStorer')
    create_kata
    start
    continue
    refute empty?
    refute full?
  end

  private

  def check_id
    params = { :format => :json, :id => @id }
    get 'enter/check', params
    assert_response :success
  end

  def empty?
    json['empty']
  end

  def full?
    json['full']
  end

end
