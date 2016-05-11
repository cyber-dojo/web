
module SetupWorker # mix-in

  module_function

  def read_custom_exercises
    dojo.runner.runnable(custom).map { |exercise| exercise.display_name }.sort
  end

  def read_languages
    dojo.runner.runnable(languages).map { |language| language.display_name }.sort
  end

  def read_exercises
    names = []
    instructions_hash =  {}
    exercises.each do |exercise|
      names << exercise.name
      instructions_hash[exercise.name] = exercise.instructions
    end
    [names.sort, instructions_hash]
  end

end
