require_relative 'lib_test_base'

class DummyDisk
  def initialize(who); @who = who; end
  def read; 'hello world:' + @who; end
end

class DummyStorer
  def initialize(who); @who = who; end
  def save; @who + ':42'; end
end

class Anna
  def disk; @disk ||= DummyDisk.new('anna'); end
  def store; @store ||= DummyStore.new('anna'); end
end

class Natalie
  def initialize(anna);@parent = anna; end
  attr_reader :parent
  def store; @store ||= DummyStorer.new('natalie'); end
end

class Ellie
  def initialize(natalie); @parent = natalie; end
  attr_reader :parent
  def uses_disk; disk.read; end
  def uses_store; store.save; end
  def uses_log; log.write; end
  private
  include NearestAncestors
  def disk; nearest_ancestors(:disk); end
  def store; nearest_ancestors(:store); end
  def log; nearest_ancestors(:log); end
end

class TestNearestAncestors < LibTestBase

  def setup
    super
    anna = Anna.new
    natalie = Natalie.new(anna)
    @ellie = Ellie.new(natalie)
  end

  test 'BF1542',
  'finds_nearest_ancestor_when_there_is_one' do
    assert_equal 'hello world:anna', @ellie.uses_disk
    assert_equal 'natalie:42', @ellie.uses_store
  end

  test 'A1EF80',
  'raises_when_parent_chain_runs_out' do
    raised = assert_raises(RuntimeError) { @ellie.uses_log }
    assert_equal 'Anna does not have a parent', raised.to_s
  end

end
