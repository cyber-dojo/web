require 'json'

class FakeDir

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
    must_exist
    return enum_for(__method__) unless block_given?
    dirs.each { |name,dir| yield name if dir[:exists] }
  end

  def write(filename, content)
    must_exist
    files[filename] = content
  end

  def write_json(filename, json)
    write(filename, JSON.unparse(json))
  end

  def read(filename)
    must_exist
    files[filename]
  end

  def read_json(filename)
    JSON.parse(read(filename))
  end

  private

  attr_reader :attr, :dirs, :files

  def must_exist
    raise StandardError.new unless exists?
  end

end