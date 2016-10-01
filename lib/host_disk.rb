
class HostDisk

  def initialize(parent)
    @parent = parent
  end

  attr_reader :parent

  def dir?(name)
    File.directory?(name)
  end

  def [](name)
    HostDir.new(self, name)
  end

end
