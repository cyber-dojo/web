require_relative 'http_helper'

class StarterStub

  def initialize(_)
  end

  def language_manifest(major_name, minor_name, exercise_name)
    # Important not to make these returned Constants
    # because I manipulate the manifest in tests,
    # eg deleting keys to test kata defaults and
    # eg setting specific id's to test kata.id completion.
    if [major_name,minor_name,exercise_name] == ['Ruby','MiniTest','Fizz_Buzz']
      return {
        "display_name" => "Ruby, MiniTest",
        "image_name" => "cyberdojofoundation/ruby_mini_test",
        "filename_extension" => ".rb",
        "tab_size" => 2,
        "runner_choice" => "stateless",
        "visible_files" => {
          "test_hiker.rb" => "require './hiker'\nrequire 'minitest/autorun'\n\nclass TestHiker < MiniTest::Test\n\n  def test_life_the_universe_and_everything\n    assert_equal 42, answer\n  end\n\nend\n",
          "hiker.rb" => "\ndef answer\n  6 * 9\nend\n",
          "cyber-dojo.sh" => "for test_file in *test*.rb\ndo\n  ruby $test_file\ndone\n",
          "output" => "",
          "instructions" => "Fizz_Buzz"
        },
        "exercise" => "Fizz_Buzz"
      }
    end

    if [major_name,minor_name,exercise_name] == ['Ruby','RSpec','Fizz_Buzz']
      return {
        "display_name" => "Ruby, RSpec",
          "image_name" => "cyberdojofoundation/ruby_rspec",
          "filename_extension" => ".rb",
          "tab_size" => 2,
          "runner_choice" => "stateful",
          "visible_files" => {
            "hiker_spec.rb" => "require './hiker'\n\ndescribe \"hiker\" do\n\n  context \"life the universe and everything\" do\n    it \"multiplies correctly\" do\n      expect(answer).to eq(42)\n    end\n  end\n\nend\n",
            "hiker.rb" => "\ndef answer\n  6 * 9\nend\n",
            "cyber-dojo.sh" => "# Test output can be formatted as progress or documentation\nrspec . --format progress",
            "output" => "",
            "instructions" => "Fizz_Buzz"
          },
          "exercise" => "Fizz_Buzz"
      }
    end

    if [major_name,minor_name,exercise_name] == ['Ruby','Test::Unit','Fizz_Buzz']
      return {
        "display_name" => "Ruby, Test::Unit",
          "image_name" => "cyberdojofoundation/ruby_test_unit",
          "filename_extension" => ".rb",
          "tab_size" => 2,
          "runner_choice" => "processful",
          "visible_files" => {
            "test_hiker.rb" => "require './hiker'\nrequire 'test/unit'\n\nclass TestHiker < Test::Unit::TestCase\n\n  def test_life_the_universe_and_everything\n    assert_equal 42, answer\n  end\n\nend\n",
            "hiker.rb" => "\ndef answer\n  6 * 9\nend\n",
            "cyber-dojo.sh" => "for test_file in *test*.rb\ndo\n  ruby $test_file\ndone\n",
            "output" => "",
            "instructions" => "Fizz_Buzz"
          },
          "exercise" => "Fizz_Buzz"
      }
    end

  end

end
