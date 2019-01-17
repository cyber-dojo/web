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

end
