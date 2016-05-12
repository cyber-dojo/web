
class CustomExercises
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
    exercises.values.each(&block)
  end

  def [](name)
    exercises[commad(name)]
  end

  include Cache

  private

  include ExternalParentChainer

  def exercises
    @exercises ||= read_cache
  end

  def read_cache
    cache = {}
    disk[cache_path].read_json(cache_filename).each do |display_name, exercise|
               dir_name = exercise['dir_name']
             image_name = exercise['image_name']
      cache[display_name] = make_exercise(dir_name, display_name, image_name)
    end
    cache
  end

  def make_cache
    cache = {}
    disk[path].each_rdir('manifest.json') do |dir_name|
      exercise = make_exercise(dir_name)
      cache[exercise.display_name] = {
             dir_name: dir_name,
           image_name: exercise.image_name
      }
    end
    cache
  end

  def make_exercise(dir_name, display_name = nil, image_name = nil)
    Language.new(self, dir_name, display_name, image_name)
  end

  def commad(name)
    name.split('-').join(', ')
  end

end
