require_relative 'app_models_test_base'

class LanguagesTest < AppModelsTestBase

  test '3C0810',
  'languages path has correct format when set with trailing slash' do
    path = tmp_root + '/' + 'folder'
    set_languages_root(path + '/')
    assert_equal path, languages.path
    assert correct_path_format?(languages)
  end

  #- - - - - - - - - - - - - - - - - - - - -

  test '3C0BB5',
  'languages path has correct format when set without trailing slash' do
    path = tmp_root + '/' + 'folder'
    set_languages_root(path)
    assert_equal path, languages.path
    assert correct_path_format?(languages)
  end

  #- - - - - - - - - - - - - - - - - - - - -

  test '3C064A',
  'cache is created on demand' do
    # be very careful here... naming languages will create languages!
    path = languages.cache_path
    filename = languages.cache_filename
    assert disk[path].exists? filename
    old_cache = disk[path].read(filename)
    `rm #{path}/#{filename}`
    refute disk[path].exists? filename
    @dojo = nil  # force dojo.languages to be new Languages object
    languages    # dojo.languages ||= Languages.new(...)
    assert disk[path].exists? filename
    new_cache = disk[path].read(filename)
    assert_equal old_cache, new_cache
  end

  #- - - - - - - - - - - - - - - - - - - - -

  test '3C0327',
  'languages[name] is nil when name is not an existing language' do
    assert_nil languages['wibble_XXX']
  end

  #- - - - - - - - - - - - - - - - - - - - -

  test '3C010F',
  'languages[X] is language named X' do
    ['C (clang)-assert', 'C#-NUnit'].each do |name|
      assert_equal name, languages[name].name
    end
  end

  #- - - - - - - - - - - - - - - - - - - - -

  test '3C0969',
  'trying to isolate test that is failing only on Travis' do
    #puts "<test 3C0969>"
    #dir = disk[languages.cache_path]
    #json = dir.read_json(languages.cache_filename)
    #puts JSON.pretty_generate(json)
    assert_equal 'C++ (g++), assert', languages.renamed('C++')
    cache = languages.read_cache
    #puts cache.keys.inspect
    assert cache.keys.include? 'C++ (g++), assert'

    refute_nil languages['C++'], 'C++'
    #puts "</test 3C0969>"
  end

  test '3C0BBE',
  'name is translated when katas manifest.json language entry has been renamed' do
    #skip
    historical_language_names do |old_name|
      unless old_name.include? 'Approval'
        refute_nil languages[old_name], old_name
      end
    end
  end

  #- - - - - - - - - - - - - - - - - - - - -

  test '3C0518',
  '[name] when lang-test where lang,_test is valid display_name' do
    #skip
    simple_case = 'C++ (g++)-assert'
    simple_display_name = 'C++ (g++), assert'
    found = languages.find { |language| language.display_name == simple_display_name }
    refute_nil found
    assert_equal simple_display_name, languages[simple_case].display_name
  end

  #- - - - - - - - - - - - - - - - - - - - -

  test '3C0B38',
  '[name] when name has no hyphen and was renamed' do
    #skip
    [
       # from way back when test name was not part of language name
      'BCPL', 'C', 'C++', 'C#', 'CoffeeScript','Erlang','Go',
      'Haskell', 'Java', 'Javascript', 'Perl', 'PHP', 'Python', 'Ruby', 'Scala',
    ].each { |name| refute_nil languages[name], name }
  end

  #- - - - - - - - - - - - - - - - - - - - -

  test '3C0D03',
  '[name] when name has hyphen and was renamed' do
    #skip
    [
      # renamed
      # 'Java-ApprovalTests', # offline
      'Java-JUnit-Mockito',
      'C++-catch',
      # works as is
      'Ruby-Test::Unit',
      'Javascript-Mocha+chai+sinon',
      'Perl-Test::Simple',
      'Python-py.test',
      'Ruby-RSpec',
      # - in the wrong place
      # 'Java-1.8_Approval', # offline
      'Java-1.8_Cucumber',
      'Java-1.8_JMock',
      'Java-1.8_JUnit',
      'Java-1.8_Mockito',
      'Java-1.8_Powermockito',
      # replaced
      'R-stopifnot',
      # renamed to distinguish from [C (clang)]
      'C-assert',
      'C-Unity',
      'C-CppUTest',
      # renamed to distinguish from [C++ (clang++)]
      'C++-assert',
      'C++-Boost.Test',
      'C++-Catch',
      'C++-CppUTest',
      'C++-GoogleTest',
      'C++-Igloo',
      'C++-GoogleMock',
      #
      'Ruby-Rspec',
      'Ruby-TestUnit',
    ].each { |name| refute_nil languages[name], name }
  end

  #- - - - - - - - - - - - - - - - - - - - -

  test '3C0017',
  '[name] on historical_language_names' do
    #skip
    historical_language_names do |name|
      refute_nil languages[name], name unless name.include? 'Approval'
    end
  end

  private

  def historical_language_names
    # these names harvested from cyber-dojo.org using
    # admin_scripts/show_kata_language_names.rb
    #
    # katas/../......../manifest.json { language: X }
    # Also listed are count of occurences on cyber-dojo.org
    # and ID of one occurrence on cyber-dojo.org
    [
      'Asm-assert 25 010E66019D',
      'BCPL 3 DF9A083C0F',
      'BCPL-all_tests_passed 18 C411C2351E',
      'C 479 54529AA3BE',
      'C# 1473 54F993C99A',
      'C#-NUnit 3088 54009537D3',
      'C#-SpecFlow 229 543E10EB15',
      'C++ 535 54E041DECA',
      'C++-Boost.Test 55 54C6A3B75B',
      'C++-Catch 352 54652F82AD',
      'C++-CppUTest 662 54A93BB04C',
      'C++-GoogleMock 19 280B752660',
      'C++-GoogleTest 1452 54C157173A',
      'C++-Igloo 46 280DB28223',
      'C++-assert 1015 545111471C',
      'C-Unity 450 5498403AF6',
      'C-assert 836 54B99F4CE2',
      #'Clojure 67 5A53D42987',          # offline
      #'Clojure-.test 177 546B4184B4',   # offline
      'CoffeeScript 47 014F4190E0',
      'CoffeeScript-jasmine 83 54219ECA71',
      'D-unittest 45 541349CE61',
      'Erlang 45 282F687601',
      'Erlang-eunit 121 543F979F1C',
      'F#-NUnit 101 5447BFDCB0',
      'Fortran-FUnit 64 016105DBCD',
      'Go 47 AA393DDF4B',
      'Go-testing 155 2849773A9C',
      'Groovy-JUnit 117 5A776302BC',
      'Groovy-Spock 109 AADE304AC9',
      'Haskell 81 23939E0066',
      'Haskell-hunit 146 28894CFFC1',
      'Java 17 23A7CF3454',
      'Java-1.8_Approval 389 54D58851FE',
      'Java-1.8_Cucumber 228 54303D90C6',
      'Java-1.8_JMock 43 C484782160',
      'Java-1.8_JUnit 3648 5437D7B510',
      'Java-1.8_Mockito 313 540E06E467',
      'Java-1.8_Powermockito 56 339F6FF85A',
      'Java-Approval 220 54624C174C',
      'Java-Cucumber 163 543D714DF5',
      'Java-JUnit 1708 54FB5612C3',
      'Java-JUnit-Mockito 160 54359DB8B5',
      'Java-Mockito 37 020B8A969E',
      'Java-PowerMockito 6 D360343B60',
      'Javascript 474 54210DA681',
      'Javascript-assert 517 549D533F36',
      'Javascript-jasmine 534 5A749EFF33',
      'Javascript-mocha_chai_sinon 128 5A405D8EE2',
      'PHP 396 54C77C53AA',
      'PHP-PHPUnit 827 541E1B649B',
      'Perl 57 549C58C8BA',
      'Perl-TestSimple 112 287BE6DEDB',
      'Python 621 54F07B407C',
      'Python-pytest 815 5496730F04',
      'Python-unittest 1242 548F3E67A7',
      'R-RUnit 37 54811DAFB1',
      'R-stopifnot 2 F0A5407B87',
      'Ruby 339 54EE119F79',
      'Ruby-Approval 149 283E57E66D',
      'Ruby-Cucumber 154 28A62BD7AA',
      'Ruby-Rspec 508 545144CA06',
      'Ruby-TestUnit 412 546A3CCA40',
      'Scala-scalatest 190 5A3EE246D6'
    ].each do |entry|
      yield entry.split[0]
    end
  end

end
