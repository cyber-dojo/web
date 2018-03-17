require_relative 'app_models_test_base'

class KatasTest < AppModelsTestBase

  def self.hex_prefix
    'F3B488'
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  # katas[id]
  #- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  test '8B1',
  'katas[bad-id] is not nil but any access to storer service raises' do
    bad_ids = [
      nil,          # not string
      Object.new,   # not string
      '',           # too short
      '123456789',  # too short
      '123456789f', # not 0-9A-F
      '123456789S'  # not 0-9A-F
    ]
    bad_ids.each do |bad_id|
      kata = katas[bad_id]
      refute_nil kata
      assert_raises { kata.age }
    end
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  test 'B3E',
  'katas[good-id] is kata with that id' do
    assert_equal kata_id, katas[kata_id].id
  end

  private

  def stub_make_kata(kata_id)
    id_generator.stub(kata_id)
    make_language_kata
    kata_id
  end

end
