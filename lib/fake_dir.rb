
class FakeDir

  def initialize(hash)
    @attr = hash
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
    must_exist
    return enum_for(__method__) unless block_given?
    dirs.each { |name,dir| yield name if dir[:exists] }
  end

  def write_json(filename, obj)
    must_exist
    files[filename] = obj
  end

  def read_json(filename)
    must_exist
    files[filename]
  end

  private

  attr_reader :attr

  def must_exist
    raise StandardError.new unless exists?
  end

  def dirs
    @dirs ||= attr[:dirs]
  end

  def files
    @files ||= attr[:files]
  end

end