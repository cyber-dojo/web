require_relative 'dir_fake'

class DiskFake

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
    DirFake.new(wd)
  end

end
