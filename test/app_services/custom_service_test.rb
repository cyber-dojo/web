require_relative 'app_services_test_base'
require_relative 'http_json_request_packer_not_json_stub'

class CustomServiceTest < AppServicesTestBase

  def self.hex_prefix
    '08A'
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - -

  test '3A7',
  'response.body failure is mapped to CustomException' do
    set_http(HttpJsonRequestPackerNotJsonStub)
    error = assert_raises(CustomException) { custom.sha }
    assert error.message.start_with?('http response.body is not JSON'), error.message
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - -

  test '3A8',
  'smoke test ready?' do
    assert custom.ready?
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - -

  test '3A9',
  'smoke test sha' do
    assert_sha custom.sha
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - -

  test '3AC',
  'smoke test names' do
    assert_equal expected_names.sort, custom.names
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - -

  test '3AF',
  'smoke test manifests' do
    manifests = custom.manifests
    assert manifests.is_a?(Hash)
    assert_equal expected_names.sort, manifests.keys.sort
    manifest = manifests['Yahtzee refactoring, C# NUnit']
    assert_is_Yahtzee_refactoring_CSharp_NUnit_manifest(manifest)
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - -

  test '3AD',
  'smoke test manifest(name)' do
    manifest = custom.manifest('Yahtzee refactoring, C# NUnit')
    assert_is_Yahtzee_refactoring_CSharp_NUnit_manifest(manifest)
  end

  private

  def expected_names
    [
      'C++ Countdown, Practice Round',
      'C++ Countdown, Round 1',
      'C++ Countdown, Round 2',
      'C++ Countdown, Round 3',
      'C++ Countdown, Round 4',
      'C++ Countdown, Round 5',
      'C++ Countdown, Round 6',
      'Java Countdown, Practice Round',
      'Java Countdown, Round 1',
      'Java Countdown, Round 2',
      'Java Countdown, Round 3',
      'Java Countdown, Round 4',
      'Tennis refactoring, C# NUnit',
      'Tennis refactoring, C++ (g++) assert',
      'Tennis refactoring, Java JUnit',
      'Tennis refactoring, Python unitttest',
      'Tennis refactoring, Ruby Test::Unit',
      'Yahtzee refactoring, C (gcc) assert',
      'Yahtzee refactoring, C# NUnit',
      'Yahtzee refactoring, C++ (g++) assert',
      'Yahtzee refactoring, Java JUnit',
      'Yahtzee refactoring, Python unitttest'
    ]
  end

  def assert_is_Yahtzee_refactoring_CSharp_NUnit_manifest(manifest)
    expected_keys = %w( display_name image_name visible_files filename_extension )
    assert_equal expected_keys.sort, manifest.keys.sort

    assert_equal 'Yahtzee refactoring, C# NUnit', manifest['display_name']
    assert_equal ['.cs'], manifest['filename_extension']
    assert_equal 'cyberdojofoundation/csharp_nunit', manifest['image_name']
    expected_filenames = %w( Yahtzee.cs YahtzeeTest.cs cyber-dojo.sh instructions )
    visible_files = manifest['visible_files']
    assert_equal expected_filenames, visible_files.keys.sort
    assert_starts_with(visible_files, 'instructions', 'The starting code and tests')
    assert_starts_with(visible_files, 'Yahtzee.cs', 'public class Yahtzee {')
    assert_starts_with(visible_files, 'YahtzeeTest.cs', 'using NUnit.Framework;')
    assert_starts_with(visible_files, 'cyber-dojo.sh', 'NUNIT_PATH=/nunit/lib/net45')
  end

end
