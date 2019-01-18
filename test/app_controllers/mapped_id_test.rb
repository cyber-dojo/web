require_relative '../../app/models/avatars'
require_relative 'app_controller_test_base'

class MappedIdTest < AppControllerTestBase

  def self.hex_prefix
    'C43'
  end

  #- - - - - - - - - - - - - - - -
  # kata/edit
  #- - - - - - - - - - - - - - - -

  test '766', 'kata/edit no mapped-id6 redirection' do
    id6 = '5rTJv5'
    get "/kata/edit/#{id6}", params:{}
    assert_response :success
  end

  #- - - - - - - - - - - - - - - -

  test '767', 'kata/edit mapped-id10 redirection' do
    id10 = '733E9E16FC'
    params = { avatar:'mouse' }
    get "/kata/edit/#{id10}", params:params
    assert_response :redirect
    regex = /^(.*)\/kata\/edit\/5rTJv5$/
    assert regex.match(@response.redirect_url)
  end

  #- - - - - - - - - - - - - - - -
  # dashboard/show
  #- - - - - - - - - - - - - - - -

  test '5AB', 'dashboard/show no mapped-id6 redirection' do
    id6 = 'FxWwrr'
    get "/dashboard/show/#{id6}", params:{}
    assert_response :success
  end

  #- - - - - - - - - - - - - - - -

  test '5AC', 'dashboard/show mapped-id10 redirection' do
    id10 = '733E9E16FC'
    get "/dashboard/show/#{id10}", params:{}
    assert_response :redirect
    regex = /^(.*)\/dashboard\/show\/FxWwrr$/
    assert regex.match(@response.redirect_url)
  end

  #- - - - - - - - - - - - - - - -
  # review/show
  #- - - - - - - - - - - - - - - -

  test '9F8', 'review/show no mapped-id6 redirection' do
    id6 = '5rTJv5'
    get "/review/show/#{id6}", params:{}
    assert_response :success
  end

  #- - - - - - - - - - - - - - - -

  test '9F9', 'review/show mapped-id10 redirection' do
    id10 = '733E9E16FC'
    params = { avatar:'mouse' }
    get "/review/show/#{id10}", params:params
    assert_response :redirect
    regex = /^(.*)\/review\/show\/5rTJv5$/
    assert regex.match(@response.redirect_url)
  end

  test '9FA', 'review/show mapped-id10 redirection with tag->index' do
    id10 = '733E9E16FC'
    params = { avatar:'mouse', was_tag:1, now_tag:2 }
    get "/review/show/#{id10}", params:params
    assert_response :redirect
    regex = /^(.*)\/review\/show\/5rTJv5\?was_index\=1\&now_index\=2$/
    assert regex.match(@response.redirect_url)
  end

  #- - - - - - - - - - - - - - - -
  # id_join
  #- - - - - - - - - - - - - - - -

  test '866', 'id_join mapped-id10 redirection with 6..10 digits' do
    id10 = '733E9E16FC'
    (6..10).each do |n|
      partial_id = id10[0...n]
      assert_equal n, partial_id.size
      kata = assert_join(partial_id)
      assert_equal 'FxWwrr', kata.group.id
    end
  end

  #- - - - - - - - - - - - - - - -
  # id_rejoin
  #- - - - - - - - - - - - - - - -

  test '9C7', 'group id_rejoin mapped-id10 redirection with 6..10 digits' do
    id10 = '733E9E16FC'
    (6..10).each do |n|
      partial_id = id10[0...n]
      assert_equal n, partial_id.size
      params = { format:'json', from:'group', id:partial_id }
      get '/id_rejoin/drop_down', params:params
      assert_response :success
      assert json['exists']
      refute json['empty']
    end
  end

  test '9C8', 'individual id_rejoin mapped-id10 redirection with 6..10 digits' do
    id10 = '733E9E16FC'
    (6..10).each do |n|
      partial_id = id10[0...n]
      params = { format:'json', from:'individual', id:partial_id }
      get '/id_rejoin/drop_down', params:params
      assert_response :success
      assert json['exists']
      assert_equal '5rTJv5', json['kataId']
      assert_equal 'mouse', json['avatarName']
    end
  end

  #- - - - - - - - - - - - - - - -
  # id_review
  #- - - - - - - - - - - - - - - -

  test '11C', 'group id_review mapped-id10 redirection with 6..10 digits' do
    id10 = '733E9E16FC'
    (6..10).each do |n|
      partial_id = id10[0...n]
      params = { format:'json', id:partial_id }
      get '/id_review/drop_down', params:params
      assert_response :success
      assert json['exists']
      assert_equal 'FxWwrr', json['id']
    end
  end

end
