require_relative 'app_controller_test_base'

class IdRejoinControllerTest < AppControllerTestBase

  def self.hex_prefix
    '881'
  end

  #- - - - - - - - - - - - - - - -

  test '405', 'show' do
    get '/id_rejoin/show?from=individual', as: :html
    assert_response :success
    get '/id_rejoin/show?from=group', as: :html
    assert_response :success
  end

  #- - - - - - - - - - - - - - - -

  test '406', %w(
  given an group-rejoin with a group-id
  when there is one or more avatar
  then show the avatar-picker ) do
    in_group do |group|
      assert_join(group.id)
      rejoin('group', group.id)
      assert exists?
      refute empty?
      assert avatarPicker?
    end
  end

  #- - - - - - - - - - - - - - - -

  test '307', %w(
  given an individual-rejoin with a group-id
  when there is only one-avatar
  then show the avatar and not the avatar-picker ) do
    in_group do |group|
      kata = assert_join(group.id)
      rejoin('individual', group.id)
      assert exists?
      refute empty?
      refute avatarPicker?
    end
  end

  #- - - - - - - - - - - - - - - -

  test '407', %w(
  given an individual-rejoin with a group-id
  when there is more than one avatar
  then show the avatar-picker  ) do
    in_group do |group|
      kata = assert_join(group.id)
      kata = assert_join(group.id)
      rejoin('individual', group.id)
      assert exists?
      refute empty?
      assert avatarPicker?
    end
  end

  #- - - - - - - - - - - - - - - -

  test '408',
  'rejoin from new empty group' do
    in_group do |group|
      rejoin('group', group.id)
      assert exists?
      assert empty?
      assert avatarPicker?
    end
  end

  #- - - - - - - - - - - - - - - -

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
    refute empty?
    refute avatarPicker?
    assert_equal 'mouse', avatar_name
  end

  #- - - - - - - - - - - - - - - -

  test '509',
  'rejoin from new individual kata' do
    in_kata do |kata|
      rejoin('individual', kata.id)
      assert exists?
      refute empty?
      refute avatarPicker?
      assert_equal '', avatar_name
    end
  end

  #- - - - - - - - - - - - - - - -

  test '50A',
  'rejoin from individual kata that does not exist' do
    rejoin('individual', '112233')
    refute exists?
  end

  #- - - - - - - - - - - - - - - -

  private

  def rejoin(from, id)
    params = { from: from, id:id }
    get '/id_rejoin/drop_down', params:params, as: :json
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

  def avatarPicker?
    !json['avatarPickerHtml'].nil?
  end

end
