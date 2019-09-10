require_relative 'lib_test_base'
require_relative '../../lib/oj_adapter'

class OjAdapterTest < LibTestBase

  def self.hex_prefix
    '2e1'
  end

  include OjAdapter

  # - - - - - - - - - - - - - - - - -

  test '191', %w( plain-parse roundtrip ) do
    s = json_plain(any_hash)
    assert_equal any_hash, json_parse(s)
  end

  test '192', %w( pretty-parse roundtrip ) do
    s = json_pretty(any_hash)
    assert_equal any_hash, json_parse(s)
  end

  private

  def any_hash
    {
      "created" => [2019,8,12, 34,56,23,5375],
      "files" => {
        "wibble.h" => {
          "content" => "#include <stdio.h>",
          "truncated" => false
        }
      },
      "image_name" => "cyberdojofoundation/gcc_assert"
    }
  end

end
