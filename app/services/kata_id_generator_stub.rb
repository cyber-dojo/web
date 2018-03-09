
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

  def stub(*kata_ids)
    storer.validate(kata_ids)
    @stubs = kata_ids
  end

  private

  def default_id
    ENV['CYBER_DOJO_TEST_ID']
  end

  def storer
    @externals.storer
  end

end
