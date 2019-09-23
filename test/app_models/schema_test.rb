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
  'existing pre-schema kata default to version=0' do
    set_saver_class('SaverService')
    assert_equal 0, katas['k5ZTk0'].schema.version
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  test 'BAB', %w(
  when you join an existing pre-schema group your kata is at version=0
  ) do
    set_saver_class('SaverService')
    group = groups['chy6BJ']
    kata = group.join
    assert_equal 0, kata.schema.version
  end

  test 'BAC', %w(
  when you join a version=1 group your kata is at version=1
  ) do
    manifest = starter_manifest
    manifest['version'] = 1
    group = groups.new_group(manifest)
    assert_equal 1, group.schema.version
    kata = group.join
    assert_equal 1, kata.schema.version
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  test '426',
  'new_group version=0' do
    group = groups.new_group(starter_manifest)
    assert_equal 0, group.schema.version
  end

  test '526',
  'new_group version=1' do
    manifest = starter_manifest
    manifest['version'] = 1
    group = groups.new_group(manifest)
    assert_equal 1, group.schema.version
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  test '427',
  'new_kata version=0' do
    kata = katas.new_kata(starter_manifest)
    assert_equal 0, kata.schema.version
  end

  test '527',
  'new_kata version=1' do
    manifest = starter_manifest
    manifest['version'] = 1
    kata = katas.new_kata(manifest)
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
