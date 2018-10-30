require_relative 'app_models_test_base'

class KataTest < AppModelsTestBase

  def self.hex_prefix
    'F3B488'
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - -

  test '860',
  'a kata with an aribtrary id does not exist' do
    refute katas['123AbZ'].exists?
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - -

  test '862', %w(
  a new kata can be created from a well-formed manifest
  is empty
  and is not a member of a group
  ) do
    manifest = starter.language_manifest('Ruby, MiniTest', 'Fizz_Buzz')
    manifest['created'] = time_now
    kata = katas.new_kata(manifest)
    assert kata.exists?

    assert_equal 0, kata.age

    assert_equal '', kata.stdout
    assert_equal '', kata.stderr
    assert_equal '', kata.status

    refute kata.active?
    assert_equal [], kata.lights

    assert_nil kata.group
    assert_equal '', kata.avatar_name

    assert_equal 'Ruby, MiniTest', kata.manifest.display_name
  end


end
