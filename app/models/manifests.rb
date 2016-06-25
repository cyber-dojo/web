
class Manifests
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
    all[commad(name)] || all[renamed(name)]
  end

  def lhs_column_name
    setup['lhs_column_name']
  end

  def rhs_column_name
    setup['rhs_column_name']
  end

  include CacheProperties

  private

  include ExternalParentChainer
  include LanguagesRename

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
    Manifest.new(self, dir_name, display_name, image_name)
  end

  def commad(name)
    name.split('-').join(', ')
  end

  def setup
    @setup ||= disk[path].read_json('setup.json')
  end

end
