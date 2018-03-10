
class KataIdGeneratorStub

  def initialize(externals)
    @externals = externals
    stub(default_id)
  end

  def generate
    if @stubs.nil? || @stubs == []
      fail self.class.name + ':out of stubs!'
    else
      @stubs.shift
    end
  end

  def stub(kata_id)
    storer.validate(kata_id)
    @stubs = [kata_id]
  end

  private

  def default_id
    ENV['CYBER_DOJO_TEST_ID']
  end

  def storer
    @externals.storer
  end

end
