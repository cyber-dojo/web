
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
    assert_valid_id(kata_id)
    refute_kata_exists(kata_id)
    @stubs = [kata_id]
  end

  private

  def default_id
    ENV['CYBER_DOJO_TEST_ID']
  end

  def assert_valid_id(kata_id)
    unless storer.valid_id?(kata_id)
      fail invalid('kata_id')
    end
  end

  def refute_kata_exists(kata_id)
    if storer.kata_exists?(kata_id)
      fail invalid('kata_id')
    end
  end

  def invalid(message)
    ArgumentError.new("invalid #{message}")
  end

  def storer
    @externals.storer
  end

end
