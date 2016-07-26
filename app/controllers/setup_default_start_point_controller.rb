
class SetupDefaultStartPointController < ApplicationController

  # Regular two step setup
  # step 1. languages+test in column 1,2   (eg Java+JUnit)
  # step 2. exercise                       (eg Fizz_Buzz)

  def show_languages
    @id = id
    @title = 'create'
    languages_names = display_names_of(languages)
    index = choose_language(languages_names, dojo.katas[id])
    @start_points = ::DisplayNamesSplitter.new(languages_names, index)
    @max_seconds = dojo.runner.max_seconds
  end

  def pull_needed
    render json: { needed: !dojo.runner.pulled?(language.image_name) }
  end

  def pull
    _output, exit_status = dojo.runner.pull(language.image_name)
    render json: { succeeded: exit_status == 0 }
  end

  def save_no_exercise
    manifest = katas.create_kata_manifest(language)
    kata = katas.create_kata_from_kata_manifest(manifest)
    render json: { id: kata.id }
  end

  def show_exercises
    @id = id
    @title = 'create'
    @language = params[:language]
    @test = params[:test]
    @exercises_names,@exercises = read_exercises
    @initial_index = choose_exercise(@exercises_names, dojo.katas[id])
  end

  def save
    manifest = katas.create_kata_manifest(language)
    exercise_name = params['exercise']
    exercise = exercises[exercise_name]
    manifest[:exercise] = exercise.name
    manifest[:visible_files]['instructions'] = exercise.text
    kata = katas.create_kata_from_kata_manifest(manifest)
    render json: { id: kata.id }
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
    languages[params['major'] + '-' + params['minor']]
  end

end
