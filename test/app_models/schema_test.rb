require_relative 'app_models_test_base'
require_relative '../../app/models/schema'

class SchemaTest < AppModelsTestBase

  def self.hex_prefix
    '187'
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  test '526',
  'new kata with version explicitly set to 0 is honoured' do
    manifest = starter_manifest
    manifest['version'] = 0
    id = model.kata_create(manifest)
    kata = katas[id]
    assert_equal 0, model.kata_manifest(id)['version']
  end

  test '527',
  'new kata with version explicitly set to 1 is honoured' do
    manifest = starter_manifest
    manifest['version'] = 1
    id = model.kata_create(manifest)
    kata = katas[id]
    assert_equal 1, model.kata_manifest(id)['version']
  end

  test '528',
  'new kata defaults to current version which is 1' do
    manifest = starter_manifest
    id = model.kata_create(manifest)
    kata = katas[id]
    assert_equal 1, model.kata_manifest(id)['version']
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  test '8DE',
  'version number is set in initializer' do
    assert_equal 0, Schema.new(self, 0).version
    assert_equal 1, Schema.new(self, 1).version
  end

end
