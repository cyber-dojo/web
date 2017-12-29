
class SetupDefaultStartPointController < ApplicationController

  # Regular two step setup
  # step 1. languages+testFramework in column 1,2
  #   (eg Java+JUnit)
  # step 2. exercise
  #   (eg Fizz_Buzz)

  def show_languages
    choices = starter.languages_choices
    current_display_name = kata.exists? ? kata.display_name : nil
    display_name_index(choices, current_display_name)
    @id = id
    @major_names   = choices['major_names']
    @major_index   = choices['major_index']
    @minor_names   = choices['minor_names']
    @minor_indexes = choices['minor_indexes']
  end

  def show_exercises
    choices = starter.exercises_choices
    current_exercise_name = kata.exists? ? kata.exercise : nil
    exercise_index(choices, current_exercise_name)
    @major = params['major']
    @minor = params['minor']
    @exercises_names = choices['names']
    @exercises       = choices['contents']
    @initial_index   = choices['index']
  end

  def save
    major = params['major']
    minor = params['minor']
    exercise = params['exercise']
    manifest = starter.language_manifest(major, minor, exercise)
    kata = katas.create_kata(manifest)
    render json: {
      image_name: kata.image_name,
              id: kata.id,
       selection: major + ', ' + minor # TODO: used?
     }
  end

  private

  include DisplayNameIndexer

  def exercise_index(choices, current_exercise_name)
    names = choices['names']
    index = names.index(current_exercise_name)
    choices['index'] = index ? index : rand(0...names.size)
  end

end
