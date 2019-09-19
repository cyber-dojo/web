require_relative 'lib_test_base'
require_relative '../../lib/cleaner'

class CleanerTest < LibTestBase

  def self.hex_prefix
    '3d9'
  end

  include Cleaner

  test '982',
  'cleaned_string cleans away invalid-encodings' do
    refute dirty.valid_encoding?
    clean = cleaned_string(dirty)
    assert clean.valid_encoding?
    refute_equal dirty, clean
  end

  # - - - - - - - - - - - - - - - - - - -

  test '983',
  'cleaned_string leaves valid strings untouched' do
    before = 'once upon a time'
    assert before.valid_encoding?
    after = cleaned_string(before)
    assert after.valid_encoding?
    assert_equal before, after
  end

  # - - - - - - - - - - - - - - - - - - -

  test '984',
  'cleaned_files cleans away invalid-encodings' do
    files = {
      '/sandbox/dirty.txt' => dirty,
      '/sandbox/clean.txt' => 'as you wish'
    }
    cleaned = cleaned_files(files)
    assert_equal ['/sandbox/clean.txt','/sandbox/dirty.txt'], cleaned.keys.sort
    cleaned.each do |filename,content|
      diagnostic = filename
      assert content.valid_encoding?, diagnostic
    end
  end

  # - - - - - - - - - - - - - - - - - - -

  test '985', %w(
  cleaned_files() cleans away invalid-encodings
  and then converts Windows line-endings
  ) do
    plain = [
      'the boy stood on',
      'the burning dec',
      dirty
    ]
    windows = plain.join("\r\n")
    before = { 'windows' => windows }
    after = cleaned_files(before)
    assert_equal ['windows'], after.keys
    content = after['windows']
    expected = plain[0..1].join("\n")
    assert content.start_with?(expected), [content,expected]
    refute content.end_with?("\r\n"), content
  end

  # - - - - - - - - - - - - - - - - - - -

  test '986',
  'cleaned_files converts Windows line-endings to Unix line-endings' do
    plain = [
      'the boy stood on',
      'the burning deck',
      'his heart was all a quiver'
    ]
    windows = plain.join("\r\n")
    unix = plain.join("\n")
    before = { 'windows' => windows }
    after = cleaned_files(before)
    assert_equal ['windows'], after.keys
    assert_equal unix, after['windows']
  end

  # - - - - - - - - - - - - - - - - - - -

  test '987',
  'cleaned_files leaves Unix line-endings untouched' do
    plain = [
      'the boy stood on',
      'the burning deck',
      'his heart was all a quiver'
    ]
    unix = plain.join("\n")
    before = { 'unix' => unix }
    after = cleaned_files(before)
    assert_equal ['unix'], after.keys
    assert_equal unix, after['unix']
  end

  private

  def dirty
    (130..135).to_a.pack('c*').force_encoding('utf-8')
  end

end
