require_relative 'app_models_test_base'
require_relative '../../app/models/groups'
require_relative '../../app/models/katas'
require_relative '../../app/models/version'

class VersionTest < AppModelsTestBase

  def self.hex_prefix
    '187'
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  test '426',
  'group version=0' do
    groups = Groups.new(self, 0)
    group = groups.new_group(starter_manifest)
    assert_equal 0, Version.for_group(self, group.id)
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  test '427',
  'kata version=0' do
    katas = Katas.new(self, 0)
    kata = katas.new_kata(starter_manifest)
    assert_equal 0, Version.for_kata(self, kata.id)
  end

end
