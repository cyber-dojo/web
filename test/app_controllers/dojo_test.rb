require_relative 'app_controller_test_base'

class DojoControllerTest < AppControllerTestBase

  def self.hex_prefix
    '1032DA'
  end

  #- - - - - - - - - - - - - - - -

  test 'BF7',
  'index without id' do
    get '/dojo/index'
    assert_response :success
  end

  #- - - - - - - - - - - - - - - -

  test '957',
  'index with id' do
    get '/dojo/index', params: { id:'1234512345' }
    assert_response :success
  end

  #- - - - - - - - - - - - - - - -

  test '78E',
  'check_id exists=false when no kata for id' do
    @id = 'abcdef'
    check_id
  end

  #- - - - - - - - - - - - - - - -

  test '90C',
  'check_id exists=true when id.length ~ 6 and kata exists' do
    [5,6,7].each { |n|
      in_kata(:stateless) {}
      @id = @id[0..(n-1)]
      assert_equal n, @id.length
      check_id
      refute empty?
      refute full?
    }
  end

  #- - - - - - - - - - - - - - - -

  test '8EE',
  'show start/resume programming, with no id' do
    get '/enter/show'
  end

  test 'E3E',
  'show start/resume programming, with an id' do
    in_kata(:stateless) {
      get '/enter/show', params: { :id => @id }
    }
  end

  #- - - - - - - - - - - - - - - -

  test 'C5A',
  'show review, with no id' do
    get '/enter/review'
  end

  test 'B19',
  'show review, with an id' do
    in_kata(:stateless) {
      get '/enter/review', params: { :id => @id }
    }
  end

  private # = = = = = = = = = = = =

  def check_id
    params = { :format => :json, :id => @id }
    get '/enter/check', params:params
    assert_response :success
  end

  def full?
    json['full']
  end

end
