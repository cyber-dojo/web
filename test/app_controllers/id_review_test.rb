require_relative 'app_controller_test_base'

class IdReviewControllerTest < AppControllerTestBase

  def self.hex_prefix
    '5EF'
  end

  #- - - - - - - - - - - - - - - -

  test '408',
  'review from existing group' do
    review('FxWwrr')
    assert exists?
    assert_equal id, 'FxWwrr'
  end

  #- - - - - - - - - - - - - - - -

  test '409',
  'review from new group' do
    in_group do |group|
      review(group.id)
      assert exists?
      assert_equal id, group.id
    end
  end

  #- - - - - - - - - - - - - - - -

  test '40A',
  'review from group that does not exist' do
    review('112233')
    refute exists?
  end

  #- - - - - - - - - - - - - - - -

  private

  def review(id)
    params = { 'format' => 'json', 'id' => id }
    get '/id_review/drop_down', params:params
    assert_response :success
  end

  def exists?
    json['exists']
  end

  def id
    json['id']
  end

end
