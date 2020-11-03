require_relative 'app_lib_test_base'

class DiffViewTest < AppLibTestBase

  def self.hex_prefix
    '836'
  end

  # - - - - - - - - - - - - - - - - - - - - - - -

  include DiffView

  def hex_setup
    set_differ_class('NotUsed')
    set_runner_class('NotUsed')
  end

  # - - - - - - - - - - - - - - - - - - - - - - -

  test '291', %w(
  simple example going from red to green
  ) do
    diffs =
    [
      {
        'type' => 'changed',
        'filename' => 'hiker.rb',
        'old_filename' => 'hiker.rb',
        'new_filename' => 'hiker.rb',
        'line_counts' => {
          'added' => 1,
          'deleted' => 1,
          'same' => 3
        },
        'lines' => [
          { 'line' => '',           'type' => 'same',    'number' => 1 },
          { 'line' => 'def answer', 'type' => 'same',    'number' => 2 },
          { 'type' => 'section', 'index' => 0 },
          { 'line' => '  6 * 9',    'type' => 'deleted', 'number' => 3 },
          { 'line' => '  6 * 7',    'type' => 'added',   'number' => 3 },
          { 'line' => 'end',        'type' => 'same',    'number' => 4 },
        ]
      }
    ]
    view = diff_view(diffs)

    expected_view =
    [
      {
        :id => "id_0",
        :type => "changed",
        :filename => "hiker.rb",
        :old_filename => "hiker.rb",
        :new_filename => "hiker.rb",
        :section_count => 1,
        :deleted_line_count => 1,
        :added_line_count => 1,
        :same_line_count => 3,
        :content =>
          "<same>&nbsp;</same>" +
          "<same>def answer</same>" +
          "<span id='id_0_section_0'></span>" +
          "<deleted>  6 * 9</deleted>" +
          "<added>  6 * 7</added>" +
          "<same>end</same>",
        :line_numbers =>
          "<same><ln>1</ln></same>" +
          "<same><ln>2</ln></same>" +
          "<deleted><ln>3</ln></deleted>" +
          "<added><ln>3</ln></added>" +
          "<same><ln>4</ln></same>"
      }
    ]
    assert_equal expected_view, view
  end

  # - - - - - - - - - - - - - - - - - - - - - - -

  test '292', %w(
  simple example of deleted file
  ) do
    diffs =
    [
      {
        'type' => 'deleted',
        'filename' => 'hiker.rb',
        'old_filename' => 'hiker.rb',
        'new_filename' => nil,
        'line_counts' => {
          'added' => 0,
          'deleted' => 3,
          'same' => 0
        },
        'lines' => [
          { 'type' => 'section', 'index' => 0 },
          { 'line' => 'def answer', 'type' => 'deleted', 'number' => 1 },
          { 'line' => '  6 * 7',    'type' => 'deleted', 'number' => 2 },
          { 'line' => 'end',        'type' => 'deleted', 'number' => 3 },
        ]
      }
    ]
    view = diff_view(diffs)

    expected_view =
    [
      {
        :id => "id_0",
        :type => "deleted",
        :filename => "hiker.rb",
        :old_filename => "hiker.rb",
        :new_filename => nil,
        :section_count => 1,
        :deleted_line_count => 3,
        :added_line_count => 0,
        :same_line_count => 0,
        :content =>
          "<span id='id_0_section_0'></span>" +
          "<deleted>def answer</deleted>" +
          "<deleted>  6 * 7</deleted>" +
          "<deleted>end</deleted>",
        :line_numbers =>
          "<deleted><ln>1</ln></deleted>" +
          "<deleted><ln>2</ln></deleted>" +
          "<deleted><ln>3</ln></deleted>"
      }
    ]
    assert_equal expected_view, view
  end

end
