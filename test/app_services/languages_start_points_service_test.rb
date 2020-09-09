require_relative 'app_services_test_base'
require_relative 'http_json_requester_not_json_stub'
require_relative '../../app/services/languages_start_points_service'

class LanguagesStartPointsServiceTest < AppServicesTestBase

  def self.hex_prefix
    '3A2'
  end

  def hex_setup
    set_languages_start_points_class('LanguagesStartPointsService')
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - -

  test '3A7',
  'response.body failure is mapped to exception' do
    set_http(HttpJsonRequesterNotJsonStub)
    error = assert_raises(LanguagesStartPointsService::Error) { languages_start_points.ready? }
    assert error.message.start_with?('http response.body is not JSON'), error.message
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - -

  test '3A9',
  'smoke test ready?' do
    assert languages_start_points.ready?
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - -

  test '3AC',
  'smoke test names' do
    assert_equal expected_names.sort, languages_start_points.names
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - -

  test '3AF',
  'smoke test manifests' do
    manifests = languages_start_points.manifests
    assert manifests.is_a?(Hash)
    assert_equal expected_names.sort, manifests.keys.sort
    manifest = manifests['C#, NUnit']
    assert_is_CSharp_NUnit_manifest(manifest)
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - -

  test '3AD',
  'smoke test manifest(name)' do
    manifest = languages_start_points.manifest('C#, NUnit')
    assert_is_CSharp_NUnit_manifest(manifest)
  end

  private

  def expected_names
    [
      "Asm, assert",
      "BCPL, all_tests_passed",
      "Bash, bash_unit", "Bash, bats", "Bash, shunit2",
      "C (clang), Cgreen", "C (clang), assert", "C (gcc), Cgreen",
      "C (gcc), CppUTest", "C (gcc), GoogleTest", "C (gcc), assert",
      "C#, Moq", "C#, NUnit", "C#, SpecFlow", "C++ (clang++), Cgreen",
      "C++ (clang++), Catch", "C++ (clang++), GoogleMock", "C++ (clang++), GoogleTest",
      "C++ (clang++), Igloo", "C++ (clang++), assert", "C++ (g++), Boost.Test",
      "C++ (g++), Catch", "C++ (g++), Cgreen", "C++ (g++), CppUTest",
      "C++ (g++), Cucumber-cpp",
      "C++ (g++), GoogleMock", "C++ (g++), GoogleTest",
      "C++ (g++), Igloo", "C++ (g++), assert",
      "Chapel, assert",
      "Clojure, Midje", "Clojure, clojure.test",
      "CoffeeScript, jasmine",
      "D, unittest",
      "Elixir, ExUnit",
      "Erlang, eunit",
      "F#, NUnit",
      "Fortran, FUnit",
      "Go, convey", "Go, testify", "Go, testing",
      "Groovy, JUnit", "Groovy, Spock",
      "Haskell, hunit",
      "Java, Approval", "Java, Cucumber", "Java, Cucumber-Spring",
      "Java, JMock", "Java, JUnit", "Java, JUnit-Sqlite", "Java, Mockito",
      "Java, PowerMockito",
      "Javascript, Cucumber", "Javascript, Mocha+chai+sinon", "Javascript, assert",
      "Javascript, assert+jQuery", "Javascript, jasmine", "Javascript, jest", "Javascript, qunit+sinon",
      "Julia, test",
      "Kotlin, Kotlintest",
      "PHP, PHPUnit",
      "Pascal (FreePascal), assert",
      "Perl, Test::Simple",
      "Prolog, plunit",
      "Python, approval-pytest", "Python, approval-unittest",
      "Python, assert", "Python, behave", "Python, pytest", "Python, unittest",
      "R, RUnit",
      "Ruby, Approval", "Ruby, Cucumber", "Ruby, MiniTest", "Ruby, RSpec", "Ruby, Test::Unit",
      "Rust, test",
      "Swift, Swordfish", "Swift, XCTest",
      "TypeScript, jest",
      "VHDL, assert",
      "VisualBasic, NUnit",
      "Zig, test"
    ]
  end

  def assert_is_CSharp_NUnit_manifest(manifest)
    expected_keys = %w( display_name filename_extension
      image_name max_seconds tab_size visible_files )
    assert_equal expected_keys.sort, manifest.keys.sort

    assert_equal 'C#, NUnit', manifest['display_name'], :display_name
    assert_equal ['.cs'], manifest['filename_extension'], :filename_extension
    assert manifest['image_name'].start_with?('cyberdojofoundation/csharp_nunit'), :image_name
    expected_filenames = %w( Hiker.cs HikerTest.cs cyber-dojo.sh )
    visible_files = manifest['visible_files']
    assert_equal expected_filenames, visible_files.keys.sort, :visible_files
    assert_starts_with(visible_files, 'Hiker.cs', 'public class Hiker')
    assert_starts_with(visible_files, 'HikerTest.cs', 'using NUnit.Framework;')
    assert_includes(visible_files, 'cyber-dojo.sh', 'NUNIT_PATH=/nunit/lib/net45')
    assert_equal 10, manifest['max_seconds'], :max_seconds
    assert_equal 4, manifest['tab_size'], :tab_size
  end

end
