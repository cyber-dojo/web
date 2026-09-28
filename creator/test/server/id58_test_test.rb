require_relative 'creator_test_base'

class Id58TestTest < CreatorTestBase

  # - - - - - - - - - - - - - - - - - - - - -

  test 'c89C80',
       'test-id is available via environment variable' do
    assert_equal 'c89C80', ENV['ID58']
  end

  # - - - - - - - - - - - - - - - - - - - - -

  test 'c8957B',
       'test-id is also available via a method' do
    assert_equal 'c8957B', id58
  end

  # - - - - - - - - - - - - - - - - - - - - -

  test 'c8918F',
       'test-name is available via a method' do
    assert_equal 'test-name is available via a method', name58
  end

  # - - - - - - - - - - - - - - - - - - - - -

  test 'c89D30',
       'test-name can be long',
       'and split over many',
       'comma separated lines',
       'and will automatically be',
       'joined with spaces' do
    expected = [
      'test-name can be long',
      'and split over many',
      'comma separated lines',
      'and will automatically be',
      'joined with spaces'
    ].join(' ')
    assert_equal expected, name58
  end

  # - - - - - - - - - - - - - - - - - - - - -

  test 'c89D31', %w[
    test-name can be long,
    and split over many lines with %w syntax,
    and will automatically be joined with spaces
  ] do
    expected = [
      'test-name can be long,',
      'and split over many lines with %w syntax,',
      'and will automatically be joined with spaces'
    ].join(' ')
    assert_equal expected, name58
  end

  # - - - - - - - - - - - - - - - - - - - - -

  test 'c89E3A', %w[id digits can be hex uppercase] do
    assert_equal 'c89E3A', ENV['ID58']
    assert_equal 'c89E3A', id58
  end

  test 'c89e3a', %w[id digits can be hex lowercase] do
    assert_equal 'c89e3a', ENV['ID58']
    assert_equal 'c89e3a', id58
  end
end
