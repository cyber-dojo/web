require_relative 'app_lib_test_base'

class MakefileFilterTest < AppLibTestBase

  include MakefileFilter

  def setup
    super
    set_storer_class('NotUsed')
    set_runner_class('NotUsed')
    set_differ_class('NotUsed')
  end

  #- - - - - - - - - - - - - - - - - - - - - -

  test 'C88333',
  'not makefile leaves leading whitespace untouched' do
    check('notMakefile', "            abc", "            abc")
    check('notMakefile', "        abc", "        abc")
    check('notMakefile', "    abc", "    abc")
    check('notMakefile', "\tabc", "\tabc")
  end

  #- - - - - - - - - - - - - - - -

  test 'C8819D',
  'makefile converts all leading whitespace on a line to a single tab' do
    check('makefile', "            abc", "\tabc")
    check('makefile', "        abc", "\tabc")
    check('makefile', "    abc", "\tabc")
    check('makefile', "\tabc", "\tabc")
  end

  #- - - - - - - - - - - - - - - -

  test 'C8803C',
  'Makefile converts all leading whitespace on a line to a single tab' do
    check('Makefile', "            abc", "\tabc")
    check('Makefile', "        abc", "\tabc")
    check('Makefile', "    abc", "\tabc")
    check('Makefile', "\tabc", "\tabc")
  end

  #- - - - - - - - - - - - - - - -

  test 'C8802B',
  'makefile converts all leading whitespace to single tab for all lines in any line format' do
    check('makefile', "123\n456", "123\n456")
    check('makefile', "123\r\n456", "123\n456")

    check('makefile', "    123\n456", "\t123\n456")
    check('makefile', "    123\r\n456", "\t123\n456")

    check('makefile', "123\n    456", "123\n\t456")
    check('makefile', "123\r\n    456", "123\n\t456")

    check('makefile', "    123\n   456", "\t123\n\t456")
    check('makefile', "    123\r\n   456", "\t123\n\t456")

    check('makefile', "    123\n456\n   789", "\t123\n456\n\t789")
    check('makefile', "    123\r\n456\n   789", "\t123\n456\n\t789")
    check('makefile', "    123\n456\r\n   789", "\t123\n456\n\t789")
    check('makefile', "    123\r\n456\r\n   789", "\t123\n456\n\t789")
  end

  private

  def check(filename, content, expected)
    assert_equal expected, makefile_filter(filename,content)
  end

end
