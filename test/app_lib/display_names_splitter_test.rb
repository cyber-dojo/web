require_relative 'app_lib_test_base'

class DisplayNamesSplitterTest < AppLibTestBase

  def setup
    super
    set_storer_class('NotUsed')
    set_runner_class('NotUsed')
    set_differ_class('NotUsed')
  end

  # - - - - - - - - - - - - - - - - - - - - - -

  test '0B2D3E',
  'display_names is split on comma into [languages_names,tests_names]' do

    display_names = [
      'C++, GoogleTest',  # 0
      'C++, assert',      # 1 <----- selected
      'C, assert',
      'C, Unity',
      'C, Igloo',
      'Go, testing'
    ]

    selected_index = display_names.index('C++, assert')
    assert_equal 1, selected_index

    split_names = DisplayNamesSplitter.new(display_names, selected_index)

    major_names = split_names.major_names
    minor_names = split_names.minor_names
    minor_indexes = split_names.minor_indexes
    initial_index = split_names.initial_index

    assert_equal [
      'C',
      'C++',  # <----- initial_index
      'Go'
    ], major_names

    assert_equal [
      'GoogleTest',  # 0
      'Igloo',       # 1
      'Unity',       # 2
      'assert',      # 3
      'testing'      # 4
    ], minor_names

    sorted_indexes =
    [
      [ # C
        1,  # Igloo   (C, Igloo)
        2,  # Unity   (C, Unity)
        3,  # assert  (C, assert)
      ],
      [ # C++
        0,  # GoogleTest  (C++, GoogleTest)
        3,  # assert      (C++, assert)         <---- selected
      ],
      [ # Go
        4,  # testing     (Go, testing)
      ]
    ]

    assert_equal sorted_indexes.length, minor_indexes.length

    sorted_indexes.each_with_index {|array,at|
      assert_equal array, minor_indexes[at].sort
    }

    assert_equal 'C++', major_names[initial_index]
    assert_equal 'assert', minor_names[minor_indexes[initial_index][0]]

  end

end
