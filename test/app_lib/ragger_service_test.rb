require_relative 'app_lib_test_base'

class RaggerServiceTest < AppLibTestBase

  test '182F5B',
  'before start-points volume re-architecture',
  'colour of output is determined by OutputColour.of()' do
    kata_id = '182F5B1E68'
    manifest = make_manifest(kata_id)
    manifest['unit_test_framework'] = 'junit'
    storer.create_kata(manifest)
    kata = katas[kata_id]
    assert_equal 'red', ragger.colour(kata, red_output)
  end

  # - - - - - - - - - - - - - - - - - - - - - - -

  test '1821E3',
  'after start-points volume re-architecture',
  'colour of output is determined by red-amber-green lambda' do
    kata_id = '1821E3CB6F'
    manifest = make_manifest(kata_id)
    manifest['red_amber_green'] = [
      "lambda { |output|",
      "  return :red   if /^Tests run: (\\d*),(\\s)+Failures: (\\d*)/.match(output)",
      "  return :green if /^OK \\((\\d*) test/.match(output)",
      "  return :amber",
      "}"
    ]
    storer.create_kata(manifest)
    kata = katas[kata_id]
    assert_equal 'red', ragger.colour(kata, red_output)
  end

  private

  def red_output
    'Tests run: 1, Failures: 1'
  end

end
