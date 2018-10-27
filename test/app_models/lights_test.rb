require_relative 'app_models_test_base'
require_relative '../app_lib/delta_maker'

class LightsTest < AppModelsTestBase

  def self.hex_prefix
    '881852'
  end

  #- - - - - - - - - - - - - - - - - - -

  test 'D3F',
  'lights initially empty' do
    in_kata {
      as(:wolf) {
        assert_equal [], wolf.lights
        assert_equal 0, wolf.lights.count
        n = 0
        wolf.lights.each { n += 1 }
        assert_equal 0, n
      }
    }
  end

  #- - - - - - - - - - - - - - - - - - -

  test '06F',
  'lights not empty' do
    in_kata {
      as(:wolf) {
        maker = DeltaMaker.new(wolf)

        runner.stub_run_colour('red')
        maker.run_test(red_time=[2014,2,15, 8,54,6])
        assert_equal 1, wolf.lights.count
        assert_equal_light 1, :red, Time.mktime(*red_time), wolf.lights[0]

        runner.stub_run_colour('amber')
        maker.run_test(amber_time=[2014,2,15, 8,54,34])
        assert_equal 2, wolf.lights.count
        assert_equal_light 2, :amber, Time.mktime(*amber_time), wolf.lights[1]

        runner.stub_run_colour('green')
        maker.run_test(green_time=[2014,2,15, 8,55,7])
        assert_equal 3, wolf.lights.count
        assert_equal_light 3, :green, Time.mktime(*green_time), wolf.lights[2]
      }
    }
    n = 0
    wolf.lights.each do |light|
      n += 1
      assert_equal 'wolf', light.avatar.name
    end
    assert_equal 3, n

    assert_equal 3, wolf.lights.length

    a = wolf.lights
    assert_equal 'Array', a.class.name
    assert_equal 'Tag', a[0].class.name
  end

  private # = = = = = = = = = = =

  def assert_equal_light expected_index, expected_colour, expected_time, light
    assert_equal expected_colour, light.colour
    assert_equal expected_time  , light.time
    assert_equal expected_index,  light.index
  end

end
