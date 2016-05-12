
class Languages
  include Enumerable

  def initialize(dojo)
    @parent = dojo
    disk[cache_path].write_json_once(cache_filename) { make_cache }
  end

  attr_reader :parent

  def path
    @path ||= parent.env('languages_root')
  end

  def each(&block)
    languages.values.each(&block)
  end

  def [](name)
    languages[commad(name)] || languages[renamed(name)]
  end

  def cache_filename
    'languages_root'.split('_')[0] + '.json'
    #'languages.json'
  end

  include CachePath

  private

  include ExternalParentChainer
  include LanguagesRename

  def languages
    @languages ||= read_cache
  end

  def read_cache
    cache = {}
    disk[cache_path].read_json(cache_filename).each do |display_name, language|
           dir_name = language['dir_name']
         image_name = language['image_name']
      cache[display_name] = make_language(dir_name, display_name, image_name)
    end
    cache
  end

  def make_cache
    cache = {}
    disk[path].each_rdir('manifest.json') do |dir_name|
      language = make_language(dir_name)
      cache[language.display_name] = {
             dir_name: dir_name,
           image_name: language.image_name
      }
    end
    cache
  end

  def make_language(dir_name, display_name = nil, image_name = nil)
    Language.new(self, dir_name, display_name, image_name)
  end

  def commad(name)
    name.split('-').join(', ')
  end

end
