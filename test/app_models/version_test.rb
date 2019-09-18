require_relative 'app_models_test_base'
require_relative '../../app/models/groups'
require_relative '../../app/models/katas'
require_relative '../../app/models/version'

class VersionTest < AppModelsTestBase

  def self.hex_prefix
    '187'
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  test 'C53',
  'existing group version=0' do
    set_saver_class('SaverService')
    assert_equal 0, groups['chy6BJ'].version.number
  end

  test 'C54',
  'existing kata version=0' do
    set_saver_class('SaverService')    
    assert_equal 0, katas['k5ZTk0'].version.number
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  test '426',
  'new_group version=0' do
    group = groups.new_group(starter_manifest)
    assert_equal 0, group.version.number
  end

  test '526',
  'new_group version=1' do
    manifest = starter_manifest
    manifest['version'] = 1
    group = groups.new_group(manifest)
    assert_equal 1, group.version.number
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  test '427',
  'new_kata version=0' do
    kata = katas.new_kata(starter_manifest)
    assert_equal 0, kata.version.number
  end

  test '527',
  'new_kata version=1' do
    manifest = starter_manifest
    manifest['version'] = 1
    kata = katas.new_kata(manifest)
    assert_equal 1, kata.version.number
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  test '8DE',
  'version numbers' do
    assert_equal 0, Version.new(self, 0).number
    assert_equal 1, Version.new(self, 1).number
  end

end
