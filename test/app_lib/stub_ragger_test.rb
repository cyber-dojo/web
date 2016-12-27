require_relative './app_lib_test_base'

class StubRaggerTest < AppLibTestBase

  def ragger
    StubRagger.new(self)
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  test 'A4EB30',
  'stub_colour with bad colour raises' do
    assert_raises { ragger.stub_colour(:blue) }
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  test 'A4E3FA',
  'stub_colour stubs given colour for subsequent run' do
    [:red, :amber, :green].each do |colour|
      ragger.stub_colour(colour)
      assert_equal colour, ragger.colour(kata=nil, output=nil)
    end
  end

end
