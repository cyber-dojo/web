require_relative './fake_dir'

class FakeDisk

  def initialize(parent)
    @parent = parent
    @root = { parent:nil, exists:true, files:{}, dirs:{} }
  end

  attr_reader :parent, :root

  def [](path)
    wd = @root
    path.split('/').each do |dir|
      wd = wd[:dirs][dir] ||= { parent:wd, exists:false, files:{}, dirs:{} }
    end
    FakeDir.new(wd)
  end

end
