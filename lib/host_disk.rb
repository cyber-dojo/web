
class HostDisk

  def initialize(_parent)
  end

  attr_reader :parent

  def dir?(name)
    File.directory?(name)
  end

  def [](name)
    HostDir.new(self, name)
  end

end
