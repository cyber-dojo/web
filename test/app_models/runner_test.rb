require_relative 'app_models_test_base'

class RunnerTest < AppModelsTestBase

  def self.hex_prefix
    'Nn2'
  end

  def hex_setup
    set_runner_class('RunnerService')
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  test '149',
  'red: expected=42, actual=6*9' do
    in_kata do |kata|
      result = kata.run_tests(params(kata, '6 * 9', '6 * 99'))
      assert_equal false, result[0]['timed_out']
      assert_equal 'red', colour_of(kata, result[0])
    end
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  test '150',
  'amber: expected=42, actual=6*7sss' do
    in_kata do |kata|
      result = kata.run_tests(params(kata, '6 * 9', '6 * 9sss'))
      assert_equal false, result[0]['timed_out']
      assert_equal 'amber', colour_of(kata, result[0])
    end
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  test '151',
  'green: expected=42, actual=6*7' do
    in_kata do |kata|
      result = kata.run_tests(params(kata, '6 * 9', '6 * 7'))
      assert_equal false, result[0]['timed_out']
      assert_equal 'green', colour_of(kata, result[0])
    end
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  test '152',
  'timed_out: infinite loop' do
    in_kata do |kata|
      result = kata.run_tests(params(kata, '6 * 9', 'loop do;end', 2))
      assert_equal true, result[0]['timed_out']
    end
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  # hidden_filenames

  private

  def params(kata, from, to, max_seconds = kata.manifest.max_seconds)
    all = {
      id:kata.id,
      image_name:kata.manifest.image_name,
      max_seconds:max_seconds,
      file_content:plain(kata.files),
      hidden_filenames:'[]'
    }
    filename = 'hiker.rb'
    src = all[:file_content][filename]
    src.sub!(from, to)
    all[:file_content][filename] = src
    all
  end

  def colour_of(kata, result)
    stdout = result['stdout']['content']
    stderr = result['stderr']['content']
    status = result['status'].to_i
    ragger.colour(kata.manifest.image_name, kata.id, stdout, stderr, status)
  end

end
