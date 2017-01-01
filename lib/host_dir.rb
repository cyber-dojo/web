
class HostDir

  def initialize(disk, path)
    @disk = disk
    @path = path
    @path += '/' unless @path.end_with?('/')
  end

  def parent
    disk
  end

  attr_reader :path

  def each_rdir(filename)
     Dir.glob(path + '**/' + filename).each do |entry|
       yield File.dirname(entry)
     end
  end

  def each_dir
    return enum_for(:each_dir) unless block_given?
    Dir.entries(path).each do |entry|
      pathed = path + entry
      yield entry if disk.dir?(pathed) && !dot?(pathed)
    end
  end

  def each_file
    return enum_for(:each_file) unless block_given?
    Dir.entries(path).each do |entry|
      pathed = path + entry
      yield entry unless disk.dir?(pathed)
    end
  end

  def exists?(filename = nil)
    return File.directory?(path) if filename.nil?
    return File.exist?(path + filename)
  end

  def make
    # Can't find a Ruby library method allowing you to do a
    # mkdir_p and know if a dir was created or not. So using shell.
    # -p creates intermediate dirs as required.
    # -v verbose mode, output each dir actually made
    output,_exit_status = shell.exec("mkdir -vp #{path}")
    output != ''
  end

  def write_json_once(filename)
    # The json cache object is not a regular 2nd parameter, it is yielded.
    # This is so it is only created if it is needed.
    make
    File.open(path + filename, File::WRONLY|File::CREAT|File::EXCL, 0644) do |fd|
      fd.write(JSON.unparse(yield)) # yield must return a json object
    end
  rescue Errno::EEXIST
  end

  def write_json(filename, object)
    fail RuntimeError.new("#{filename} doesn't end in .json") unless filename.end_with? '.json'
    write(filename, JSON.unparse(object))
  end

  def write(filename, s)
    fail RuntimeError.new('not a string') unless s.is_a? String
    pathed_filename = path + filename
    File.open(pathed_filename, 'w') { |fd| fd.write(s) }
  end

  def read_json(filename)
    fail RuntimeError.new("#{filename} doesn't end in .json") unless filename.end_with? '.json'
    content = read(filename)
    if content.empty?
      message = "#{self.class.name}(#{path}).read_json(#{filename}) - empty file"
      fail RuntimeError.new(message)
    end
    JSON.parse(content)
  end

  def read(filename)
    cleaned(IO.read(path + filename))
  end

  private

  include NearestAncestors
  include StringCleaner

  attr_reader :disk

  def dot?(name)
    name.end_with?('/.') || name.end_with?('/..')
  end

  def shell; nearest_ancestors(:shell); end

end
