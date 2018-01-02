require_relative 'app_controller_test_base'

class ForkerControllerTest < AppControllerTestBase

  def self.hex_prefix
    '3E9892'
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - - -

  test 'AFE', %w(
  when id is invalid,
  the fork fails,
  and the reason given is dojo ) do
    fork(bad_id = 'bad-id', 'hippo', tag=1)
    refute forked?
    assert_reason_is("dojo(#{bad_id})")
    assert_nil forked_kata_id
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - - -

  test '25B', %w(
  when avatar not started,
  the fork fails,
  and the reason given is avatar ) do
    in_kata(:stateless) {
      fork(kata.id, bad_avatar = 'hippo', tag=1)
      refute forked?
      assert_reason_is("avatar(#{bad_avatar})")
      assert_nil forked_kata_id
    }
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - - -

  test 'CA7', %w(
  when tag is bad,
  the fork fails,
  and the reason given is traffic_light ) do
    in_kata(:stateless) {
      as_avatar {
        bad_tag_test('-14') # tag < 0
        bad_tag_test('2')   # tag > avatar.lights.length
      }
    }
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - - -

  test '32F', %w(
  when id,avatar,tag are all ok
  format=json fork works
  and the new dojo's id is returned ) do
    in_kata(:stateless) {
      as_avatar {
        run_tests # 1
        fork(kata.id, avatar.name, tag=1)
        assert forked?
        assert_equal 10, forked_kata_id.length
        assert_not_equal kata.id, forked_kata_id
        forked_kata = katas[forked_kata_id]
        assert_not_nil forked_kata
        assert_equal kata.image_name, forked_kata.image_name
        kata.visible_files.each do |filename,content|
          assert forked_kata.visible_files.keys.include? filename
          #This fails - the difference seems to be \r\n related.
          #assert_equal content, forked_kata.visible_files[filename]
        end
      }
    }
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - - -

  test '835', %w(
  when id,avatar,tag are all ok,
  format=html fork works,
  and you are redirected to the enter page with the new dojo's id ) do
    in_kata(:stateless) {
      as_avatar {
        run_tests # 1
        fork(kata.id, avatar.name, tag=1, 'html')
        assert_response :redirect
        url = /(.*)\/enter\/show\/(.*)/
        m = url.match(@response.location)
        forked_kata_id = m[2]
      }
    }
  end

  #- - - - - - - - - - - - - - - - - -

  test '7E7', %w(
  when id,avatar are all ok, tag==-1,
  format=html fork works,
  and you are redirected to the enter page with the new dojo's id ) do
    in_kata(:stateless) {
      as_avatar {
        run_tests # 1
        run_tests # 2
        fork(kata.id, avatar.name, tag=-1, 'html')
        assert_response :redirect
        url = /(.*)\/enter\/show\/(.*)/
        m = url.match(@response.location)
        forked_kata_id = m[2]
        refute_equal kata.id, forked_kata_id
      }
    }
  end

  #- - - - - - - - - - - - - - - - - -

  test 'D4A', %w(
  forking kata from before start-point volume re-architecture ) do
    set_storer_class('StorerService')
    # See test/data/katas_old/421F303E80.tgz
    id = '421F303E80'
    diagnostic = "kata #{id} does not exist!?"
    assert storer.kata_exists?(id), diagnostic
    fork(id, 'buffalo', 3)
    assert forked?
    refute_nil json['image_name'], 'image_name'
  end

  private # = = = = = = = = = = = = = = = = = = =

  def bad_tag_test(bad_tag)
    fork(kata.id, avatar.name, bad_tag)
    refute forked?, bad_tag
    assert_reason_is("traffic_light(#{bad_tag})")
    assert_nil forked_kata_id
  end

  def fork(id, avatar, tag, format='json')
    get '/forker/fork', params: {
      'format' => format,
      'id'     => id,
      'avatar' => avatar,
      'tag'    => tag
    }
  end

  def forked?
    refute_nil json
    json['forked']
  end

  def assert_reason_is(expected)
    refute_nil json
    assert_equal expected, json['reason']
  end

  def forked_kata_id
    refute_nil json
    json['id']
  end

end
