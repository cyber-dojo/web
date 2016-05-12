
class Exercises
  include Enumerable

  def initialize(dojo)
    @parent = dojo
    disk[cache_path].write_json_once(cache_filename) { make_cache }
  end

  attr_reader :parent

  def path
    @path ||= parent.env('exercises_root')
  end

  def each(&block)
    exercises.values.each(&block)
  end

  def [](name)
    exercises[name]
  end

  def cache_filename
    'exercises_root'.split('_')[0] + '.json'
    #'exercises.json'
  end

  include CachePath

  private

  include ExternalParentChainer

  def exercises
    @exercises ||= read_cache
  end

  def read_cache
    cache = {}
    disk[cache_path].read_json(cache_filename).each do |name, exercise|
      cache[name] = make_exercise(name, exercise['instructions'])
    end
    cache
  end

  def make_cache
    # TODO: use disk[path].rdir globbing
    cache = {}
    disk[path].each_dir do |sub_dir|
      exercise = make_exercise(sub_dir)
      cache[exercise.name] = { instructions: exercise.instructions }
    end
    cache
  end

  def make_exercise(name, instructions = nil)
    Exercise.new(self, name, instructions)
  end

end
