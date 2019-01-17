require_relative '../../app/models/avatars'
require_relative 'app_controller_test_base'

class MappedTest < AppControllerTestBase

  def self.hex_prefix
    'C43'
  end

  #- - - - - - - - - - - - - - - -
  # kata/edit
  #- - - - - - - - - - - - - - - -

  test '766', 'kata/edit no mapped redirection' do
    id = '5rTJv5'
    get "/kata/edit/#{id}", params:{}
    assert_response :success
  end

  #- - - - - - - - - - - - - - - -

  test '767', 'kata/edit mapped redirection' do
    id = '733E9E16FC'
    params = { avatar:'mouse' }
    get "/kata/edit/#{id}", params:params
    assert_response :redirect
    regex = /^(.*)\/kata\/edit\/5rTJv5\?$/
    assert regex.match(@response.redirect_url)
  end

  #- - - - - - - - - - - - - - - -
  # dashboard/show
  #- - - - - - - - - - - - - - - -

end
