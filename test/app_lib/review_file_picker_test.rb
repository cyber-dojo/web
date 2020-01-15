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
  Rule 1: when the current-filename exists
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
  else Rule 2:
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
  else Rule 3:
  when a non-filenameExtension file has a diff
  pick the largest diff
  ) do
    @current_filename = 'hiker.h'
    @diffs = [] <<
      fdiff('hiker.h',0,0) <<
      fdiff('hiker.c',0,0) <<
      fdiff('cyber-dojo.sh',2,3) <<
      (@picked=fdiff('makefile',4,4))
    assert_picked
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - -

  test 'D92', %w(
  else Rule 4:
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

  test 'D93', %w(
  else Rule 5:
  pick largest of stdout/stderr, when it is not empty
  ) do
    @current_filename = 'hiker.h'
    @diffs = [] <<
      fdiff('hiker.test.c',0,0) <<
      fdiff('hiker.c',0,0) <<
      fdiff('cyber-dojo.sh',0,0) <<
      fdiff('makefile',0,0) <<
      fdiff('stdout',0,0,'xxx') <<
      (@picked=fdiff('stderr',0,0,'xxxx'))
    assert_picked

    @diffs = [] <<
      fdiff('hiker.test.c',0,0) <<
      fdiff('hiker.c',0,0) <<
      fdiff('cyber-dojo.sh',0,0) <<
      fdiff('makefile',0,0) <<
      fdiff('stderr',0,0,'xxx') <<
      (@picked=fdiff('stdout',0,0,'xxxx'))
    assert_picked
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - -

  test 'D94', %w(
  else Rule 6:
  pick cyber-dojo.sh
  ) do
    @current_filename = 'hiker.h'
    @diffs = [] <<
      fdiff('hiker.test.c',0,0) <<
      fdiff('hiker.c',0,0) <<
      fdiff('hiker.test.c',0,0) <<
      fdiff('makefile',0,0) <<
      fdiff('stdout',0,0,'') <<
      fdiff('stderr',0,0,'') <<
      (@picked=fdiff('cyber-dojo.sh',0,0))
    assert_picked
  end

  private

  def fdiff(filename, dc, ac, content = '')
    @n += 1
    {
      :filename => filename,
      :deleted_line_count => dc,
      :added_line_count => ac,
      :id => 'id_' + @n.to_s,
      :content => content
    }
  end

  def assert_picked
    id = pick_file_id(@diffs, @current_filename, @filenameExtension)
    assert_equal @picked[:id], id
  end

end
