require_relative 'app_controller_test_base'

class ForkerControllerTest < AppControllerTestBase

  # This test (3E99D85BF) depends on the languages start-point being complete.

=begin
  test '3E99D85BF',
  'when language has been renamed and everything else',
  'is ok then fork works and the new dojos id is returned' do
    language = languages['C#-NUnit']
    manifest = language.create_kata_manifest
    manifest['language'] = 'C#' # old-name
    katas.create_kata(manifest)
    @id = manifest['id']
    @avatar = start # 0
    run_tests       # 1
    fork(@id, @avatar.name, tag=1)
    assert forked?
  end
=end

  # - - - - - - - - - - - - - - - - - - - - - - - - - - -

  test '3E9892AFE',
  'when id is invalid then fork fails and the reason given is dojo' do
    fork(bad_id = 'bad-id', 'hippo', tag=1)
    refute forked?
    assert_reason_is("dojo(#{bad_id})")
    assert_nil forked_kata_id
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - - -

  test '3E967725B',
  'when avatar not started, the fork fails, and the reason given is avatar' do
    id = create_kata
    fork(id, bad_avatar = 'hippo', tag=1)
    refute forked?
    assert_reason_is("avatar(#{bad_avatar})")
    assert_nil forked_kata_id
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - - -

  test '3E94CCCA7',
  'when tag is bad, the fork fails, and the reason given is traffic_light' do
    @id = create_kata
    @avatar = start
    bad_tag_test('xx')      # !is_tag
    bad_tag_test('-14')     # tag <= 0
    bad_tag_test('-1')      # tag <= 0
    bad_tag_test('0')       # tag <= 0
    run_tests
    bad_tag_test('2')       # tag > avatar.lights.length
  end

  def bad_tag_test(bad_tag)
    fork(@id, @avatar.name, bad_tag)
    refute forked?
    assert_reason_is("traffic_light(#{bad_tag})")
    assert_nil forked_kata_id
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - - -

  test '3E92C432F',
  'when id,language,avatar,tag are all ok',
  'format=json fork works',
  "and the new dojo's id is returned" do
    @id = create_kata
    @avatar = start # 0
    run_tests       # 1
    fork(@id, @avatar.name, tag=1)
    assert forked?
    assert_equal 10, forked_kata_id.length
    assert_not_equal @id, forked_kata_id
    forked_kata = katas[forked_kata_id]
    assert_not_nil forked_kata
    kata = @avatar.kata
    assert_equal kata.image_name, forked_kata.image_name
    kata.visible_files.each do |filename,content|
      unless filename == 'output'
        assert forked_kata.visible_files.keys.include? filename
        #assert_equal content, forked_kata.visible_files[filename]
      end
    end
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - - -

  test '3E9F65835',
  'when id,language,avatar,tag are all ok',
  'format=html fork works',
  "and you are redirected to the enter page with the new dojo's id" do
    @id = create_kata
    @avatar = start # 0
    run_tests       # 1
    fork(@id, @avatar.name, tag=1, 'html')
    assert_response :redirect
    url = /(.*)\/enter\/show\/(.*)/
    m = url.match(@response.location)
    forked_kata_id = m[2]
  end

  #- - - - - - - - - - - - - - - - - -

  test '3E9F657E7',
  'when id,language,avatar are all ok, tag==-1',
  'format=html fork works',
  "and you are redirected to the enter page with the new dojo's id" do
    @id = create_kata
    @avatar = start # 0
    run_tests       # 1
    run_tests       # 2
    fork(@id, @avatar.name, tag=-1, 'html')
    assert_response :redirect
    url = /(.*)\/enter\/show\/(.*)/
    m = url.match(@response.location)
    forked_kata_id = m[2]
  end

  #- - - - - - - - - - - - - - - - - -

  test '3E95EA04E',
  'when the exercise no longer exists and everything else',
  'is ok then fork works and the new dojos id is returned' do
    language = languages[default_language_name]
    manifest = language.create_kata_manifest
    manifest['exercise'] = 'exercise-name-that-does-not-exist'
    katas.create_kata(manifest)
    @id = manifest['id']
    @avatar = start # 0
    run_tests       # 1
    fork(@id, @avatar.name, tag=1)
    assert forked?
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - - -

  test '3E9467D4A',
  'forking kata from before start-point volume re-architecture works' do
    language = languages['C (gcc)-assert']
    manifest = language.create_kata_manifest
    manifest.delete('red_amber_green')
    manifest['unit_test_framework'] = 'assert'
    katas.create_kata(manifest)
    @id = manifest['id']
    @avatar = start # 0
    run_tests       # 1
    fork(@id, @avatar.name, tag=1)
    assert forked?
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - - -

  private

  def fork(id, avatar, tag, format='json')
    get 'forker/fork',
      'format' => format,
      'id'     => id,
      'avatar' => avatar,
      'tag'    => tag
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
