require_relative 'app_services_test_base'
require_relative '../../app/services/saver_service'
require_relative 'saver_fake'

class SaverFakeTest < AppServicesTestBase

  def self.hex_prefix
    '6AA'
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - -

  REAL_TEST_MARK = '<saver-real>'
  FAKE_TEST_MARK = '<saver-fake>'

  def fake_test?
    hex_test_name.start_with?(FAKE_TEST_MARK)
  end

  def self.multi_saver_test(hex_suffix, *lines, &block)
    real_lines = [REAL_TEST_MARK] + lines
    test(hex_suffix+'0', *real_lines, &block)
    fake_lines = [FAKE_TEST_MARK] + lines
    test(hex_suffix+'1', *fake_lines, &block)
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - -

  def saver
    if fake_test?
      @saver ||= SaverFake.new(self)
    else
      @saver ||= SaverService.new(self)
    end
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - -
  # ready?

  multi_saver_test '602',
  %w( ready? is always true ) do
    assert saver.ready?
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - -
  # exists?(), create()

  multi_saver_test '431',
  'exists?(k) is false before create(k) and true after' do
    dirname = 'client/34/f7/a8'
    refute saver.run(saver.exists_command(dirname))
    assert saver.run(saver.create_command(dirname))
    assert saver.run(saver.exists_command(dirname))
  end

  multi_saver_test '432',
  'create succeeds once and then fails' do
    dirname = 'client/r5/s7/03'
    assert saver.run(saver.create_command(dirname))
    refute saver.run(saver.create_command(dirname))
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - -
  # write()

  multi_saver_test '640', %w(
    write() succeeds
    when its dir-name exists and its file-name does not exist
  ) do
    dirname = 'client/32/fg/9j'
    assert saver.run(saver.create_command(dirname))
    filename = dirname + '/events.json'
    content = '{"time":[3,4,5,6,7,8]}'
    assert saver.run(saver.write_command(filename, content))
    assert_equal content, saver.run(saver.read_command(filename))
  end

  multi_saver_test '641', %w(
    write() fails
    when its dir-name does not already exist
  ) do
    dirname = 'client/5e/94/Aa'
    # no saver.run(saver.create_command(dirname))
    filename = dirname + '/readme.md'
    refute saver.run(saver.write_command(filename, 'bonjour'))
    assert saver.run(saver.read_command(filename)).is_a?(FalseClass)
  end

  multi_saver_test '642', %w(
    write() fails
    when its file-name already exists
  ) do
    dirname = 'client/73/Ff/69'
    assert saver.run(saver.create_command(dirname))
    filename = dirname + '/readme.md'
    first_content = 'greetings'
    assert saver.run(saver.write_command(filename, first_content))
    refute saver.run(saver.write_command(filename, 'second-content'))
    assert_equal first_content, saver.run(saver.read_command(filename))
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - -
  # append()

  multi_saver_test '840', %w(
    append() returns true and appends to the end of file-name
    when file-name already exists
  ) do
    dirname = 'client/69/1b/2B'
    assert saver.run(saver.create_command(dirname))
    filename = dirname + '/readme.md'
    content = 'helloooo'
    assert saver.run(saver.write_command(filename, content))
    more = 'some-more'
    assert saver.run(saver.append_command(filename, more))
    assert_equal content+more, saver.run(saver.read_command(filename))
  end

  multi_saver_test '841', %w(
    append() returns false and does nothing
    when its dir-name does not already exist
  ) do
    dirname = 'client/96/18/59'
    # no saver.run(saver.create_command(dirname))
    filename = dirname + '/readme.md'
    refute saver.run(saver.append_command(filename, 'greetings'))
    assert saver.run(saver.read_command(filename)).is_a?(FalseClass)
  end

  multi_saver_test '842', %w(
    append() does nothing and returns false
    when its file-name does not already exist
  ) do
    dirname = 'client/96/18/59'
    assert saver.run(saver.create_command(dirname))
    filename = dirname + '/hiker.h'
    # no saver.run(saver.write_command(filename, '...'))
    refute saver.run(saver.append_command(filename, 'int main(void);'))
    assert saver.run(saver.read_command(filename)).is_a?(FalseClass)
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - -
  # read()

  multi_saver_test '437',
  'read() gives back what a successful write() accepts' do
    dirname = 'client/FD/F4/38'
    assert saver.run(saver.create_command(dirname))
    filename = dirname + '/limerick.txt'
    content = 'the boy stood on the burning deck'
    assert saver.run(saver.write_command(filename, content))
    assert_equal content, saver.run(saver.read_command(filename))
  end

  multi_saver_test '438',
  'read() returns false given a non-existent file-name' do
    filename = 'client/1z/23/e4/not-there.txt'
    assert saver.run(saver.read_command(filename)).is_a?(FalseClass)
  end

  multi_saver_test '439',
  'read() returns false given an existing dir-name' do
    dirname = 'client/2f/7k/3P'
    saver.run(saver.create_command(dirname))
    assert saver.run(saver.read_command(dirname)).is_a?(FalseClass)
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - -
  # run_all()

  multi_saver_test '514',
  'run_all() runs all primitive commands' do
    expected = []
    commands = []
    dirname = 'client/e3/t6/A8'
    commands << saver.create_command(dirname)
    expected << true
    commands << saver.exists_command(dirname)
    expected << true

    there_yes = dirname + '/there-yes.txt'
    content = 'inchmarlo'
    commands << saver.write_command(there_yes,content)
    expected << true
    commands << saver.append_command(there_yes,content)
    expected << true

    there_not = dirname + '/there-not.txt'
    commands << saver.append_command(there_not,'nope')
    expected << false

    commands << saver.read_command(there_yes)
    expected << content*2

    commands << saver.read_command(there_not)
    expected << false

    result = saver.run_all(commands)
    assert_equal expected, result
  end

end
