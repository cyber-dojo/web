require_relative 'test_base'
require_source 'helpers/gatherer'
require_source 'helpers/avatars_progress'

class GatheredTest < TestBase

  include GathererHelper

  attr_reader :params

  test '450s46', %w(
  | contract-test for gather from saved cyber-dojo group v0
  ) do
    id = 'chy6BJ'
    expected_indexes = {
      'k5ZTk0' => 11
    }
    expected_lights = {
      'k5ZTk0' => [
        tcpi([2019, 1, 19, 12, 45, 19, 994_317], :red, 'none', 1),
        tcpi([2019, 1, 19, 12, 45, 26, 76_791], :amber, 'none', 2),
        tcpi([2019, 1, 19, 12, 45, 30, 656_924], :green, 'none', 3)
      ]
    }
    @params = { id: id }
    gather
    gather_check(expected_indexes, expected_lights)
  end

  test '450s47', %w(
  | contract-test for gather from saved cyber-dojo group v1
  ) do
    id = 'LyQpFr'
    expected_indexes = {
      'rUqcey' => 26,
      '38w9NC' => 27
    }
    expected_lights = {
      'rUqcey' => [
        tcpi([2020, 11, 30, 14, 6, 39, 366_362], :green, 'none', 1),
        tcpi([2020, 11, 30, 14, 6, 53, 941_739], :green, 'none', 2)
      ],
      '38w9NC' => [
        tcpi([2020, 11, 30, 14, 7, 28, 706_554], :red, 'none', 1)
      ]
    }
    @params = { id: id }
    gather
    gather_check(expected_indexes, expected_lights)
  end

  private

  def gather_check(expected_indexes, expected_lights)
    assert_equal expected_indexes, @all_indexes
    actual_lights = {}
    expected_indexes.each_key do |id|
      actual_lights[id] = flat_lights(id)
    end
    assert_equal expected_lights, actual_lights
  end

  def tcpi(time_a, colour, predicted, index)
    {
      'time_a' => time_a,
      'colour' => colour,
      'predicted' => predicted,
      'index' => index
    }
  end

  def flat_lights(id)
    @all_lights[id].map do |light|
      tcpi(
        light.time_a,
        light.colour,
        light.predicted,
        light.index
      )
    end
  end
end
