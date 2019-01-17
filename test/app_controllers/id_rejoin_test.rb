require_relative 'app_controller_test_base'

class IdRejoinControllerTest < AppControllerTestBase

  def self.hex_prefix
    '881'
  end

  #- - - - - - - - - - - - - - - -

  test '407',
  'rejoin from existing group (with one kata)' do
    rejoin('group', 'FxWwrr')
    assert exists?
    refute empty?
  end

  test '408',
  'rejoin from new group' do
    in_group do |group|
      rejoin('group', group.id)
      assert exists?
      assert empty?
    end
  end

  test '409',
  'rejoin from group that does not exist' do
    rejoin('group', '112233')
    refute exists?
  end

  #- - - - - - - - - - - - - - - -

  test '508',
  'rejoin from existing individual kata' do
    rejoin('individual', '5rTJv5')
    assert exists?
    assert_equal 'mouse', avatar_name
  end

  test '509',
  'rejoin from new individual kata' do
    in_kata do |kata|
      rejoin('individual', kata.id)
      assert exists?
      assert_equal '', avatar_name
    end
  end

  test '50A',
  'rejoin from individual kata that does not exist' do
    rejoin('individual', '112233')
    refute exists?
  end

  #- - - - - - - - - - - - - - - -

  private

  def rejoin(from, id)
    params = { format:'json', id:id, from: from }
    get '/id_rejoin/drop_down', params:params
    assert_response :success
  end

  def exists?
    json['exists']
  end

  def empty?
    json['empty']
  end

  def avatar_name
    json['avatarName']
  end

end
