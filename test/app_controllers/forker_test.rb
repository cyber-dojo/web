require_relative 'app_controller_test_base'

class ForkerControllerTest < AppControllerTestBase

  def self.hex_prefix
    '3E9'
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - - -

  test '32E', %w(
  when id,index are all ok
  format=json fork_individual works
  and the new individual session's id is returned ) do
    in_kata { |kata|
      post_run_tests # 1
      fork_individual(kata.id, index=1)
      assert forked?
      forked_kata = katas[json['id']]
      assert forked_kata.exists?
      refute forked_kata.group?
      assert_equal kata.manifest.image_name, forked_kata.manifest.image_name
      assert_equal kata.files, forked_kata.files
    }
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - - -

  test '32F', %w(
  when id,index are all ok
  format=json fork_group works
  and the new group session's id is returned ) do
    in_kata { |kata|
      post_run_tests # 1
      fork_group(kata.id, index=1)
      assert forked?
      forked_group = groups[json['id']]
      assert forked_group.exists?
      assert_equal kata.manifest.image_name, forked_group.manifest.image_name
    }
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - - -

  test '8B1', %w(
  when id,index are all ok
  format=html fork_individual works
  and redirects to kata/edit ) do
    in_kata { |kata|
      post_run_tests # 1
      fork_individual(kata.id, index=1, :html)
      assert_response :redirect
      regex = /^(.*)\/kata\/edit\/([0-9A-Za-z]*)$/
      assert m = regex.match(@response.redirect_url)
      forked_id = m[2]
      assert_equal 6, forked_id.size
      forked_kata = katas[forked_id]
      assert forked_kata.exists?
    }
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - - -

  test 'AF2', %w( when id is malformed the fork fails ) do
    fork_individual(malformed_id = 'bad-id', index=1)
    refute forked?
  end

  test 'AF3', %w( when id does not exist the fork fails ) do
    fork_individual(id = '112233', index=1)
    refute forked?
  end

  test 'AF4', %w( when tag is bad the fork fails ) do
    in_kata { |kata|
      fork_individual(kata.id, index=1)
      refute forked?
      fork_individual(kata.id, index=-34)
      refute forked?
      fork_individual(kata.id, index=27)
      refute forked?
    }
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - - -
=begin
  test '835', %w(
  when id,avatar,tag are all ok,
  format=html fork works,
  and you are redirected to the group landing page with the new dojo's id ) do
    in_kata {
      as_avatar {
        run_tests # 1
        fork(kata.id, avatar.name, tag=1, 'html')
        assert_response :redirect
        url = /(.*)\/kata\/group\/(.*)/
        m = url.match(@response.location)
        forked_kata_id = m[2]
      }
    }
  end

  #- - - - - - - - - - - - - - - - - -

  test '7E7', %w(
  when id,avatar are all ok, tag==-1,
  format=html fork works,
  and you are redirected to the group landing page with the new dojo's id ) do
    in_kata {
      as_avatar {
        run_tests # 1
        run_tests # 2
        fork(kata.id, avatar.name, tag=-1, 'html')
        assert_response :redirect
        url = /(.*)\/kata\/group\/(.*)/
        m = url.match(@response.location)
        forked_kata_id = m[2]
        refute_equal kata.id, forked_kata_id
      }
    }
  end
=end

  private # = = = = = = = = = = = = = = = = = = =

  def fork_individual(id, index, format=:json)
    params = { id:id, index:index }
    get '/forker/fork_individual', params:params, as: format
  end

  def fork_group(id, index, format=:json)
    params = { id:id, index:index }
    get '/forker/fork_group', params:params, as: format
  end

  def forked?
    refute_nil json
    json['forked']
  end

end
