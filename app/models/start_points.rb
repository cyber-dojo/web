
class StartPoints
  include Enumerable

  def initialize(parent, key)
    @parent = parent
    @key = key
    @path = env_var.value(@key)
    disk[cache_path].write_json_once(cache_filename) { make_cache }
  end

  attr_reader :parent, :path

  def each(&block)
    all.values.each(&block)
  end

  def [](name)
    all[commad(name)] || all[renamed(name)]
  end

  include CacheProperties

  private

  include StartPointsRename

  def all
    @all ||= read_cache
  end

  def make_cache
    cache = {}
    disk[path].each_rdir('manifest.json') do |dir_name|
      its = make(dir_name)
      cache[its.display_name] = { dir_name: dir_name, image_name: its.image_name }
    end
    cache
  end

  def read_cache
    cache = {}
    disk[cache_path].read_json(cache_filename).each do |display_name, hash|
      cache[display_name] = make(hash['dir_name'], display_name, hash['image_name'])
    end
    cache
  end

  def make(dir_name, display_name = nil, image_name = nil)
    StartPoint.new(self, dir_name, display_name, image_name)
  end

  def commad(name)
    name.split('-', 2).join(', ')
  end

  include NearestAncestors
  def env_var; nearest_ancestors(:env_var); end
  def disk; nearest_ancestors(:disk); end

end
