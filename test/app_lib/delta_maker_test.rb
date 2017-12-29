require_relative 'app_lib_test_base'
require_relative 'delta_maker'

class DeltaMakerTest < AppLibTestBase

  def self.hex_prefix
    'A63245'
  end

  def hex_setup
    kata = make_language_kata
    avatar = kata.start_avatar(Avatars.names)
    @maker = DeltaMaker.new(avatar)
    @existing_filename = 'cyber-dojo.sh'
    assert @maker.now.keys.include?(@existing_filename)
    @new_filename = 'sal.mon'
    refute @maker.now.keys.include?(@new_filename)
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - -

  test 'CD3',
  'new_file(filename) raises RuntimeError when filename not new' do
    assert_raises(RuntimeError) { @maker.new_file(@existing_filename, '') }
  end
  #- - - - - - - - - - - - - - - - - - - - - - - - -

  test '849',
  'after new_file(filename) filename is not new' do
    @maker.new_file(@new_filename, 'any')
    assert_raises(RuntimeError) { @maker.new_file(@new_filename, '') }
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - -

  test '907',
  'change_file(filename) raises RuntimeError when filename is new' do
    assert_raises(RuntimeError) { @maker.change_file(@new_filename, '') }
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - -

  test 'D76',
  'change_file(filename) raises RuntimeError when content is unchanged' do
    content = @maker.now[@existing_filename]
    assert_raises(RuntimeError) { @maker.change_file(@existing_filename, content) }
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - -

  test '137',
  'delete_file(filename) raises RuntimeError when filename is new' do
    assert_raises(RuntimeError) { @maker.delete_file(@new_filename) }
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - -

  test '9BC',
  'after delete_file(filename) filename is not present' do
    @maker.delete_file(@existing_filename)
    assert_raises(RuntimeError) { @maker.delete_file(@existing_filename) }
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - -

  test '5D8',
  'new_file(filename) succeeds when filename is new',
  ', adds filename to visible_files',
  ', delta[:new] includes filename' do
    content = 'Snaelda'
    @maker.new_file(@new_filename, content)
    delta, now = *@maker.test_args
    assert now.keys.include?(@new_filename)
    assert_equal content, now[@new_filename]
    assert delta[:new].include?(@new_filename)
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - -

  test '9D7',
  'change_file(filename) succeeds when filename is not new and content is new',
  ", updates filename's content in visible_files",
  ', delta[:changed] includes filename' do
    new_content = 'Snaelda'
    @maker.change_file(@existing_filename, new_content)
    delta, now = *@maker.test_args
    assert now.keys.include?(@existing_filename)
    assert_equal new_content, now[@existing_filename]
    assert delta[:changed].include?(@existing_filename)
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - -

  test 'B76',
  'delete_file(filename) succeeds when filename is not new',
  ', removes filename from visible_files',
  ', delta[:deleted] includes filename' do
    @maker.delete_file(@existing_filename)
    delta, now = *@maker.test_args
    refute now.keys.include?(@existing_filename)
    assert delta[:deleted].include?(@existing_filename)
  end

end
