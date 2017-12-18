
class SetupDefaultStartPointController < ApplicationController

  # Regular two step setup
  # step 1. languages+test in column 1,2   (eg Java+JUnit)
  # step 2. exercise                       (eg Fizz_Buzz)

  def show_languages
    @id = id
    @title = 'create'
    languages_names = display_names_of(languages)
    kata = storer.kata_exists?(id) ? dojo.katas[id] : nil
    index = choose_language(languages_names, kata)
    @start_points = ::DisplayNamesSplitter.new(languages_names, index)
  end

  def show_exercises
    @id = id
    @title = 'create'
    @language = params['language']
    @test = params['test']
    @exercises_names,@exercises = read_exercises
    kata = storer.kata_exists?(id) ? dojo.katas[id] : nil
    @initial_index = choose_exercise(@exercises_names, kata)
  end

  def save
    manifest = language.create_kata_manifest
    exercise_name = params['exercise']
    exercise = exercises[exercise_name]
    manifest['exercise'] = exercise.name
    manifest['visible_files']['instructions'] = exercise.text
    kata = katas.create_kata(manifest)
    render json: {
      image_name: kata.image_name,
              id: kata.id,
       selection: major + ', ' + minor
     }
  end

  private

  include StartPointChooser

  def display_names_of(start_points)
    start_points.map(&:display_name).sort
  end

  def read_exercises
    names = []
    hash =  {}
    exercises.each do |exercise|
      names << exercise.name
      hash[exercise.name] = exercise.text
    end
    [names.sort, hash]
  end

  def language
    languages[major + '-' + minor]
  end

  def major
    params['major']
  end

  def minor
    params['minor']
  end

end
