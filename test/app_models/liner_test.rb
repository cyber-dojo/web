require_relative 'app_models_test_base'
require_relative '../../app/models/liner'

class LinerTest < AppModelsTestBase

  def self.hex_prefix
    'B45'
  end

  include Liner

  #- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  test '7AA',
  'lined(event) splits lines files/stdout/stderr and does not alter argument' do
    assert_equal LINED_EVENT, lined(UNLINED_EVENT)
    assert_equal UNLINED_EVENT['files']['test_hiker.rb']['content'], UNLINED_TEST_HIKER_RB
    assert_equal UNLINED_EVENT['files']['hiker.rb']['content'], UNLINED_HIKER_RB
    assert_equal UNLINED_EVENT['stdout']['content'], UNLINED_STDOUT
    assert_equal UNLINED_EVENT['stderr']['content'], UNLINED_STDERR
  end

  # - - - - - - - - - - - - - - - - - - - - - -

  test '7AB',
  'unlined(event) rejoins files/stdout/stderr and does not alter argument' do
    assert_equal UNLINED_EVENT, unlined(LINED_EVENT)
    assert_equal LINED_EVENT['files']['test_hiker.rb']['content'], LINED_TEST_HIKER_RB
    assert_equal LINED_EVENT['files']['hiker.rb']['content'], LINED_HIKER_RB
    assert_equal LINED_EVENT['stdout']['content'], LINED_STDOUT
    assert_equal LINED_EVENT['stderr']['content'], LINED_STDERR
  end

  private

  UNLINED_TEST_HIKER_RB = "require 'sss'\nxxx"
  UNLINED_HIKER_RB = "def x\nend\n"
  UNLINED_STDOUT = "aa\nbb\ncc"
  UNLINED_STDERR = "dd\nee\n"

  UNLINED_EVENT = {
    'files' => {
      'test_hiker.rb' => {
        'content' => UNLINED_TEST_HIKER_RB,
        'truncated' => false
      },
      'hiker.rb' => {
        'content' => UNLINED_HIKER_RB,
        'truncated' => false
      }
    },
    'stdout' => {
      'content' => UNLINED_STDOUT,
      'truncated' => false
    },
    'stderr' => {
      'content' => UNLINED_STDERR,
      'truncated' => false
    },
    'status' => 0
  }

  # - - - - - - - - - - - - - - - - - - - - - - - - -

  LINED_TEST_HIKER_RB = [ "require 'sss'\n", "xxx" ]
  LINED_HIKER_RB = [ "def x\n", "end\n" ]
  LINED_STDOUT = [ "aa\n", "bb\n", "cc" ]
  LINED_STDERR = [ "dd\n", "ee\n" ]

  LINED_EVENT = {
    'files' => {
      'test_hiker.rb' => {
        'content' => LINED_TEST_HIKER_RB,
        'truncated' => false
      },
      'hiker.rb' => {
        'content' => LINED_HIKER_RB,
        'truncated' => false
      }
    },
    'stdout' => {
      'content' => LINED_STDOUT,
      'truncated' => false
    },
    'stderr' => {
      'content' => LINED_STDERR,
      'truncated' => false
    },
    'status' => 0
  }

end
