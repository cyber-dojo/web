
class Instructions
  include Enumerable

  def initialize(dojo, key)
    @parent = dojo
    @key = key
    disk[cache_path].write_json_once(cache_filename) { make_cache }
  end

  attr_reader :parent

  def path
    @path ||= parent.env(@key)
  end

  def each(&block)
    all.values.each(&block)
  end

  def [](name)
    all[name]
  end

  include CacheInfo

  private

  include ExternalParentChainer

  def all
    @all ||= read_cache
  end

  def make_cache # TODO: use disk[path].rdir globbing
    cache = {}
    disk[path].each_dir do |dir_name|
      cache[dir_name] = { text: make(dir_name).text }
    end
    cache
  end

  def read_cache
    cache = {}
    disk[cache_path].read_json(cache_filename).each do |name, hash|
      cache[name] = make(name, hash['text'])
    end
    cache
  end

  def make(dir_name, text = nil)
    Instruction.new(self, dir_name, text)
  end

end
