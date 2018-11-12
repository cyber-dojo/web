require_relative 'app_services_test_base'
require 'json'

class GrouperServiceTest < AppServicesTestBase

  def self.hex_prefix
    'D2w'
  end

  def hex_setup
    set_differ_class('NotUsed')
    set_storer_class('NotUsed')
    set_runner_class('NotUsed')
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - -

  test '443',
  'non-existant id raises exception' do
    id = kata_id
    error = assert_raises {
      grouper.manifest(id)
    }
    assert_equal 'ServiceError', error.class.name
    assert_equal 'GrouperService', error.service_name
    assert_equal 'manifest', error.method_name
    exception = JSON.parse(error.message)
    refute_nil exception
    assert_equal 'ArgumentError', exception['class']
    assert_equal 'id:invalid', exception['message']
    assert_equal 'Array', exception['backtrace'].class.name
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - -

  test '444',
  'smoke test grouper.sha' do
    assert_sha grouper.sha
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - -

  test '6E7',
  %w( retrieved manifest contains id ) do
    manifest = make_manifest
    id = grouper.create(manifest)
    manifest['id'] = id
    assert_equal manifest, grouper.manifest(id)
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - -

  test '5F9', %w(
  after create() then
  the id can be completed
  and id?() is true
  and the manifest can be retrieved ) do
    id = grouper.create(make_manifest)
    assert grouper.id?(id)
    assert_equal id, grouper.id_completed(id[0..5])
    outer = id[0..1]
    inner = id[2..-1]
    id_completions = grouper.id_completions(outer)
    assert id_completions.include?(outer+inner)
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - -

  test '722',
  'join/joined' do
    id = grouper.create(make_manifest)
    joined = grouper.joined(id)
    assert_equal({}, joined, 'someone has already joined!')
    (1..4).to_a.each do |n|
      index,sid = *grouper.join(id)
      assert index.is_a?(Integer), "#{n}: index is a #{index.class.name}!"
      assert (0..63).include?(index), "#{n}: index(#{index}) not in (0..63)!"
      assert sid.is_a?(String), "#{n}: sid is a #{id.class.name}!"
      joined = grouper.joined(id)
      assert joined.is_a?(Hash), "#{n}: joined is a #{hash.class.name}!"
      assert_equal n, joined.size, "#{n}: incorrect size!"
      diagnostic = "#{n}: #{sid}, #{index}, #{joined}"
      assert_equal sid, joined[index.to_s], diagnostic
    end
  end

  private

  def make_manifest
    manifest = starter.language_manifest('Java, JUnit', 'Fizz_Buzz')
    manifest['created'] = creation_time
    manifest
  end

end
