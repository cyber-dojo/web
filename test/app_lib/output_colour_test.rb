require_relative 'app_lib_test_base'
require_relative '../../app/lib/unit_test_framework_lookup'

class OutputColourTest < AppLibTestBase

  def setup
    super
    set_storer_class('NotUsed')
    set_runner_class('NotUsed')
    set_differ_class('NotUsed')
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  test '900D7D',
  'all saved Runner outputs are correctly coloured red/amber/green by OutputColour.of' do
    disk[output_path].each_dir do |unit_test_framework|
      ['red', 'amber', 'green'].each do |expected|
        path = "#{output_path}/#{unit_test_framework}/#{expected}"
        dir = disk[path]
        assert dir.exists?, "#{path} does not exist"
        dir.each_file do |filename|
          output = dir.read(filename)
          actual = OutputColour::of(unit_test_framework, output)
          diagnostic = '' +
            "OutputColour::of(output)\n" +
            "  output read from: #{path}/#{filename}\n"
          assert_equal expected, actual, diagnostic
        end
      end
    end
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  test '9005E7',
  'all dojo.languages have corresponding test/app_lib/output/unit_test_framework' do
    count = 0
    dojo.languages.each do |language|
      count += 1
      unit_test_framework = lookup(language.display_name)
      refute unit_test_framework.nil?, language.display_name
      path = output_path + '/' + unit_test_framework
      diagnostic = '' +
        "language: #{language.name}\n" +
        "unit_test_framework: #{unit_test_framework}\n" +
        "...#{path}/ does not exist"
      assert disk[path].exists?, diagnostic
    end
    assert count > 0, 'no languages'
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  test '900763',
  "all dojo.languages red_amber_green lambda's correctly colour saved Runner outputs" do
    dojo.languages.each do |language|
      src = language.red_amber_green
      refute_nil src
      ['red', 'amber', 'green'].each do |expected|
        unit_test_framework = lookup(language.display_name)
        refute_nil unit_test_framework, "no lookup() for #{language.display_name}"
        path = "#{output_path}/#{unit_test_framework}/#{expected}"
        dir = disk[path]
        assert dir.exists?, "#{path} does not exist"
        dir.each_file do |filename|
          output = dir.read(filename)
          red_amber_green = eval(src.join("\n"))
          actual = red_amber_green.call(output).to_s
          diagnostic = '' +
            "#{language.name}\n" +
            "#{unit_test_framework}\n" +
            "output read from: #{path}/#{filename}\n" +
            "red_amber_green.call()"
          assert_equal expected, actual, diagnostic
        end
      end
    end
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  private

  include UnitTestFrameworkLookup

  def output_path
    File.expand_path(File.dirname(__FILE__)) + '/output'
  end

end

# If a player creates a cyberdojo.sh file which runs two
# test files then it's possible the first one will pass and
# the second one will have a failure.
# The tests could be improved...
# Each language+test_framework test file will be data-driven
# an array of green output
# an array of red output, and
# an array of amber output.
# Then the tests should verify that each has its correct
# colour individually, and also that
# any amber + any red => amber
# any amber + any green => amber
# any green + any red => red

