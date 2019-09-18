require_relative 'app_models_test_base'
require_relative '../../app/models/schema'

class SchemaTest < AppModelsTestBase

  def self.hex_prefix
    '187'
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  test 'C53',
  'existing group version=0' do
    set_saver_class('SaverService')
    assert_equal 0, groups['chy6BJ'].schema.version
  end

  test 'C54',
  'existing kata version=0' do
    set_saver_class('SaverService')
    assert_equal 0, katas['k5ZTk0'].schema.version
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
  'version numbers' do
    assert_equal 0, Schema.new(self, 0).version
    assert_equal 1, Schema.new(self, 1).version
  end

end
