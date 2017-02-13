require_relative 'app_lib_test_base'

class RaggerStubTest < AppLibTestBase

  def ragger
    RaggerStub.new(self)
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

  # - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  test 'A4E902',
  'stub set in one thread has to be visible in another thread',
  'because app_controller methods are routed into a new thread' do
    ragger.stub_colour(:green)
    stubbed_colour = nil
    tid = Thread.new {
      stubbed_colour = ragger.colour(kata=nil, output=nil)
    }
    tid.join
    assert_equal :green, stubbed_colour
  end

end
