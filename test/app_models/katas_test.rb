require_relative './app_models_test_base'

class KatasTest < AppModelsTestBase

  def setup
    super
    set_storer_class('FakeStorer')
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  # katas[id]
  #- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  test 'F3B8B1',
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

  test '075B3E',
  'katas[good-id] is kata with that id' do
    kata = make_kata
    k = katas[kata.id]
    refute_nil k
    assert_equal k.id, kata.id
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  # katas.completed(id)
  #- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  test '105939',
  'completed(id="") is empty string' do
    assert_equal '', katas.completed('')
  end

  test 'B936E2',
  'completed(id) does not complete when id is less than 6 chars in length',
  'because trying to complete from a short id will waste time going through',
  'lots of candidates (on disk) with the likely outcome of no unique result' do
    id = unique_id[0..4]
    assert_equal 5, id.length
    assert_equal id, katas.completed(id)
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  test 'A7003B',
  'completed(id) unchanged when no matches' do
    id = unique_id
    (0..7).each { |size| assert_equal id[0..size], katas.completed(id[0..size]) }
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  test '7970AA',
  'completed(id) does not complete when 6+ chars and more than one match' do
    uncompleted_id = 'ABCDE1'
    make_kata({ 'id' => uncompleted_id + '234' + '5' })
    make_kata({ 'id' => uncompleted_id + '234' + '6' })
    assert_equal uncompleted_id, katas.completed(uncompleted_id)
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  test 'ADC2AF',
  'completed(id) completes when 6+ chars and 1 match' do
    completed_id = 'A1B2C3D4E5'
    make_kata({ 'id' => completed_id })
    uncompleted_id = completed_id.downcase[0..5]
    assert_equal completed_id, katas.completed(uncompleted_id)
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  # katas.each
  #- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  test '9F12BA',
  'each() yielding empty array when there are no katas' do
    assert_equal [], all_ids
  end

  test '29C86F',
  'each() yielding one kata' do
    kata = make_kata
    assert_equal [kata.id], all_ids
  end

  test '10D000',
  'each() yielding two katas with unrelated ids' do
    kata1 = make_kata
    kata2 = make_kata
    assert_equal [kata1.id, kata2.id].sort, all_ids.sort
  end

  test 'BB0A82',
  'each() yielding several kata with common first two characters' do
    id = 'ABCDE1234'
    assert_equal 10-1, id.length
    kata1 = make_kata({ 'id' => id + '1' })
    kata2 = make_kata({ 'id' => id + '2' })
    kata3 = make_kata({ 'id' => id + '3' })
    assert_equal [kata1.id, kata2.id, kata3.id].sort, all_ids.sort
  end

  def all_ids
    # katas is Enumerable so .each not needed if doing map
    katas.map { |kata| kata.id }
  end

end
