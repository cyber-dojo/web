#!/bin/bash ../test_wrapper.sh

require_relative './app_models_test_base'

class KatasTest < AppModelsTestBase

  test 'F3B8B1',
  'attempting to access a Kata with an invalid is nil' do
    bad_ids = [
      nil,          # not string
      Object.new,   # not string
      '',           # too short
      '123456789',  # too short
      '123456789f', # not 0-9A-F
      '123456789S'  # not 0-9A-F
    ]
    bad_ids.each do |bad_id|
      begin
        kata = katas[bad_id]
        assert_nil kata
      rescue StandardError
      end
    end
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  test '075B3E',
  'katas[id] is kata with existing id' do
    kata = make_kata
    k = katas[kata.id]
    refute_nil k
    assert_equal k.id, kata.id
  end

end
