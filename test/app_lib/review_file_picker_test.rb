require_relative 'app_lib_test_base'

class ReviewFilePickerTest < AppLibTestBase

  def self.hex_prefix
    '9EF'
  end

  include ReviewFilePicker

  def hex_setup
    set_differ_class('NotUsed')
    set_runner_class('NotUsed')
    @filenameExtension = [ '.h', '.c' ]
    @n = -1
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - -

  test 'D89', %w(
  When the current-filename exists
  and has at least one diff, then pick it,
  even if a filenameExtension has a bigger diff
  ) do
    @current_filename = 'readme.txt'
    @diffs = [] <<
      fdiff('hiker.c',22,32) <<
      (@picked=fdiff(@current_filename,3,1))
    assert_picked
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - -

  test 'D90', %w(
  else
  when a filenameExtension file has a diff
  pick the largest diff
  ) do
    @current_filename = 'hiker.h'
    @diffs = [] <<
      fdiff('hiker.h',0,0) <<
      fdiff('hiker.c',2,3) <<
      (@picked=fdiff('hiker.test.c',3,3))
    assert_picked
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - -

  test 'D91', %w(
  else
  when a non-filenameExtension file has a diff
  pick the largest diff
  ) do
    @current_filename = 'hiker.h'
    @diffs = [] <<
      fdiff('hiker.h',0,0) <<
      fdiff('hiker.c',0,0) <<
      fdiff('cyber-dojo.sh',2,3) <<
      (@picked=deleted_file('makefile',4,4))
    assert_picked
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - -

  test 'x91', %w(
  else
  when the only changes are 100% identical renames
  pick the largest
  ) do
    @current_filename = 'hiker.h'
    @diffs = [] <<
      fdiff('hiker.h',0,0) <<
      fdiff('hiker.c',0,0) <<
      fdiff('cyber-dojo.sh',0,0) <<
      renamed_file('fubar.c','fubar.cpp',0,0,4) <<
      (@picked=renamed_file('Makefile','makefile',0,0,5))
    assert_picked
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - -

  test 'D92', %w(
  else
  when the current_filename exists (with no diff), pick it
  ) do
    @current_filename = 'hiker.h'
    @diffs = [] <<
      (@picked=fdiff('hiker.h',0,0)) <<
      fdiff('hiker.c',0,0) <<
      fdiff('cyber-dojo.sh',0,0) <<
      fdiff('makefile',0,0)
    assert_picked
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - -

  test 'D94', %w(
  else
  pick cyber-dojo.sh
  ) do
    @current_filename = 'hiker.h'
    @diffs = [] <<
      fdiff('hiker.test.c',0,0) <<
      fdiff('hiker.c',0,0) <<
      fdiff('hiker.test.c',0,0) <<
      fdiff('makefile',0,0) <<
      fdiff('stdout',0,0) <<
      fdiff('stderr',0,0) <<
      (@picked=fdiff('cyber-dojo.sh',0,0))
    assert_picked
  end

  private

  def fdiff(filename, dc, ac)
    a_diff('changed', filename, filename, dc, ac, 0)
  end

  def deleted_file(filename, dc, ac)
    a_diff('deleted', filename, nil, dc, ac, 4)
  end

  def renamed_file(old_filename, new_filename, dc, ac, sc)
    a_diff('renamed',  old_filename, new_filename, dc, ac, sc)
  end

  def a_diff(type, old_filename, new_filename, dc, ac, sc)
    @n += 1
    {
      :type => type,
      :old_filename => old_filename,
      :new_filename => new_filename,
      :line_counts => { deleted:dc, added:ac, same:sc },
      :id => 'id_' + @n.to_s
    }
  end

  def assert_picked
    id = pick_file_id(@diffs, @current_filename, @filenameExtension)
    assert_equal @picked[:id], id
  end

end
