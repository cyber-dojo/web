
class CustomExercises
  include Enumerable

  def initialize(dojo)
    @parent = dojo
    @path = unslashed(dojo.env('custom', 'root'))
    disk[cache_path].write_json_once(cache_filename) { make_cache }
  end

  attr_reader :path, :parent

  def each(&block)
    exercises.values.each(&block)
  end

  def [](name)
    exercises[commad(name)]
  end

  def cache_path
    File.expand_path('..', File.dirname(__FILE__)) + '/caches'
  end

  def cache_filename
    'custom_cache.json'
  end

  private

  include ExternalParentChainer
  include Unslashed

  def exercises
    @exercises ||= read_cache
  end

  def read_cache
    cache = {}
    disk[cache_path].read_json(cache_filename).each do |display_name, exercise|
               dir_name = exercise['dir_name']
             image_name = exercise['image_name']
      cache[display_name] = make_language(dir_name, display_name, image_name)
    end
    cache
  end

  def make_cache
    cache = {}
    disk[path].each_dir do |dir_name|
      disk[path + '/' + dir_name].each_dir do |exercise_dir_name|
        full_path = path + '/' + dir_name + '/' + exercise_dir_name
        exercise = make_language(full_path)
        cache[exercise.display_name] = {
                   dir_name: full_path,
                 image_name: exercise.image_name
        }
      end
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
