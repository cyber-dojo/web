
class DirFake

  def initialize(hash)
    @attr = hash
    @dirs  = hash[:dirs]
    @files = hash[:files]
  end

  def exists?
    attr[:exists]
  end

  def make
    result = !exists?
    wd = attr
    begin
      wd[:exists] = true
    end while wd = wd[:parent]
    result
  end

  def each_dir
    assert_exists
    unless block_given?
      return enum_for(__method__)
    end
    dirs.each { |name,dir|
      if dir[:exists]
        yield name
      end
    }
  end

  def write(filename, content)
    assert_exists
    files[filename] = content
  end

  def read(filename)
    assert_exists
    files[filename]
  end

  private # = = = = = = = = = =

  attr_reader :attr, :dirs, :files

  def assert_exists
    unless exists?
      fail StandardError.new
    end
  end

end
