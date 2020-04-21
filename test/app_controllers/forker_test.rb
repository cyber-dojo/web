require_relative 'app_controller_test_base'

class ForkerControllerTest < AppControllerTestBase

  def self.hex_prefix
    '3E9'
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - - -
  # format: json
  # - - - - - - - - - - - - - - - - - - - - - - - - - - -

  test '32E', %w(
  when id,index are all ok
  format=json fork_individual works
  and the new individual session's id is returned
  and designates a kata at schema.version==1) do
    in_kata { |kata|
      post_run_tests # 1
      fork_individual(kata.id, index=1)
      assert forked?
      forked_kata = katas[json['id']]
      assert forked_kata.exists?
      assert_equal 1, forked_kata.schema.version
      refute forked_kata.group?
      assert_equal kata.manifest.image_name, forked_kata.manifest.image_name
      assert_equal kata.files, forked_kata.files
    }
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - - -

  test '32F', %w(
  when id,index are all ok
  format=json fork_group works
  and the new group session's id is returned
  and designates a group at schema.version==1) do
    in_kata { |kata|
      post_run_tests # 1
      fork_group(kata.id, index=1)
      assert forked?
      forked_group = groups[json['id']]
      assert forked_group.exists?
      assert_equal 1, forked_group.schema.version
      assert_equal kata.manifest.image_name, forked_group.manifest.image_name
    }
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - - -
  # format: html
  # - - - - - - - - - - - - - - - - - - - - - - - - - - -

  test '7D4', 'forker/fork forks a group session (html)' do
    # See https://blog.cyber-dojo.org/2014/08/custom-starting-point.html
    in_kata { |kata|
      post_run_tests # 1
      params = { index:1 }
      get "/forker/fork/#{kata.id}", params:params, as: :html
      assert_response :redirect
      regex = /^(.*)\/kata\/group\/([0-9A-Za-z]*)$/
      assert m = regex.match(@response.redirect_url)
      gid = m[2]
      assert_equal 6, gid.size
      group = groups[gid]
      assert group.exists?
    }
  end

  test '7D5', 'forker/fork with tag=-1 (html)' do
    in_kata { |kata|
      post_run_tests # 1
      params = { index:-1 }
      get "/forker/fork/#{kata.id}", params:params, as: :html
      assert_response :redirect
      regex = /^(.*)\/kata\/group\/([0-9A-Za-z]*)$/
      assert m = regex.match(@response.redirect_url)
      gid = m[2]
      assert_equal 6, gid.size
      group = groups[gid]
      assert group.exists?
    }
  end

  test '7D6', 'forker/fork_group (html)' do
    in_kata { |kata|
      post_run_tests # 1
      params = { index:1 }
      get "/forker/fork_group/#{kata.id}", params:params, as: :html
      assert_response :redirect
      regex = /^(.*)\/kata\/group\/([0-9A-Za-z]*)$/
      assert m = regex.match(@response.redirect_url)
      gid = m[2]
      assert_equal 6, gid.size
      group = groups[gid]
      assert group.exists?
    }
  end

  test '7D7', 'forker/fork_individual (html)' do
    in_kata { |kata|
      post_run_tests # 1
      params = { index:1 }
      get "/forker/fork_individual/#{kata.id}", params:params, as: :html
      assert_response :redirect
      regex = /^(.*)\/kata\/edit\/([0-9A-Za-z]*)$/
      assert m = regex.match(@response.redirect_url)
      kid = m[2]
      assert_equal 6, kid.size
      kata = katas[kid]
      assert kata.exists?
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

  private # = = = = = = = = = = = = = = = = = = =

  def fork_individual(id, index, format = :json)
    get '/forker/fork_individual', params: {
      format:format,
      id:id,
      index:index
    }
  end

  def fork_group(id, index, format = :json)
    get '/forker/fork_group', params: {
      format:format,
      id:id,
      index:index
    }
  end

  def forked?
    refute_nil json
    json['forked']
  end

end
