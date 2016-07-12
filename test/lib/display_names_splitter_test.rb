#!/bin/bash ../test_wrapper.sh

require_relative './lib_test_base'

class DisplayNamesSplitterTest < LibTestBase

  test '0B2D3E',
  'display_names is split on comma into [languages_names,tests_names]' do

    # At present
    # o) the languages' display_names combine the name of the
    #    language *and* the name of the test framework.
    #
    # It makes sense to mirror the pattern of each language having its
    # own docker image, and sub folders underneath it add their
    # own test framework, and implicitly use their parents folder's
    # docker image to build FROM in their Dockerfile

    languages_display_names = [
      'C++, GoogleTest',  # 0
      'C++, assert',      # 1 <----- selected
      'C, assert',
      'C, Unity',
      'C, Igloo',
      'Go, testing'
    ]

    selected_index = languages_display_names.index('C++, assert')
    assert_equal 1, selected_index

    split_names = DisplayNamesSplitter.new(languages_display_names, selected_index)

    assert_equal [
      'C',
      'C++',  # <----- selected_index
      'Go'
    ], split_names.major

    assert_equal [
      'GoogleTest',  # 0
      'Igloo',       # 1
      'Unity',       # 2
      'assert',      # 3
      'testing'      # 4
    ], split_names.minor

    # Need to know which tests names to display and initially select
    # Make the indexes *not* sorted and the
    # first entry in each array is the initial selection

    indexes =
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

    actual = split_names.minor_indexes
    assert_equal indexes.length, actual.length

    indexes.each_with_index {|array,at|
      assert_equal array, actual[at].sort
    }

    assert_equal 1, split_names.initial_index         # C++
    assert_equal 3, split_names.minor_indexes[1][0]    # assert

  end

end
