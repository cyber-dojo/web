require_relative 'app_models_test_base'
require_relative '../../app/models/schema'

class SchemaTest < AppModelsTestBase

  def self.hex_prefix
    '187'
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  test 'C53',
  'existing pre-schema group defaults to version=0' do
    set_saver_class('SaverService')
    assert_equal 0, groups['chy6BJ'].schema.version
  end

  test 'C54',
  'existing pre-schema kata defaults to version=0' do
    set_saver_class('SaverService')
    assert_equal 0, katas['k5ZTk0'].schema.version
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  test 'BAB', %w(
  when you join a version=0 group your kata is at version=0
  ) do
    set_saver_class('SaverService')
    v0_gid = 'FxWwrr'
    group = groups[v0_gid]
    kata = group.join
    assert_equal 0, kata.schema.version
  end

  test 'BAC', %w(
  when you join a version=1 group your kata is at version=1
  ) do
    set_saver_class('SaverService')
    v1_gid = 'REf1t8'
    group = groups[v1_gid]
    kata = group.join
    assert_equal 1, kata.schema.version
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  test '426',
  'new group with version explicitly set to 0 is honoured' do
    manifest = starter_manifest
    manifest['version'] = 0
    id = model.group_create(manifest)
    group = groups[id]
    assert_equal 0, group.schema.version
  end

  test '427',
  'new group with version explicitly set to 1 is honoured' do
    manifest = starter_manifest
    manifest['version'] = 1
    id = model.group_create(manifest)
    group = groups[id]
    assert_equal 1, group.schema.version
  end

  test '428',
  'new group defaults to current version which is 1' do
    manifest = starter_manifest
    id = model.group_create(manifest)
    group = groups[id]
    assert_equal 1, group.schema.version
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  test '526',
  'new kata with version explicitly set to 0 is honoured' do
    manifest = starter_manifest
    manifest['version'] = 0
    id = model.kata_create(manifest)
    kata = katas[id]
    assert_equal 0, kata.schema.version
  end

  test '527',
  'new kata with version explicitly set to 1 is honoured' do
    manifest = starter_manifest
    manifest['version'] = 1
    id = model.kata_create(manifest)
    kata = katas[id]
    assert_equal 1, kata.schema.version
  end

  test '528',
  'new kata defaults to current version which is 1' do
    manifest = starter_manifest
    id = model.kata_create(manifest)
    kata = katas[id]
    assert_equal 1, kata.schema.version
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  test '8DE',
  'version number is set in initializer' do
    assert_equal 0, Schema.new(self, 0).version
    assert_equal 1, Schema.new(self, 1).version
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  test 'F48', %w(
  group.schema.version uses params[:version] if present
  which avoids any saver-service call
  ) do
    set_saver_class('Unused')
    id = '64327a'
    [0,1].each do |version|
      group = Group.new(self, {version:version, id:id})
      schema = group.schema
      assert_equal version, schema.version
      assert_equal id, group.id
      case version
      when 0 then assert schema.group.is_a?(Group_v0)
      when 1 then assert schema.group.is_a?(Group_v1)
      end
    end
  end

  test 'F49', %w(
  group.schema.version uses params[:version] if present
  which avoids any saver-service call
  ) do
    set_saver_class('Unused')
    id = '52d425'
    [0,1].each do |version|
      kata = Kata.new(self, {version:version, id:id})
      schema = kata.schema
      assert_equal version, schema.version
      assert_equal id, kata.id
      case version
      when 0 then schema.kata.is_a?(Kata_v0)
      when 1 then schema.kata.is_a?(Kata_v1)
      end
    end
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  # a newly created group is at the latest schema version
  # a newly created kata is at the latest schema version
  # a newly forked kata is at the latest schema version
  # a newly forked group is at the latest schema version

end
