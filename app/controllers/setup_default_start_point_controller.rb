
class SetupDefaultStartPointController < ApplicationController

  # Regular two step setup
  # step 1. languages+testFramework in column 1,2   (eg Java+JUnit)
  # step 2. exercise                                (eg Fizz_Buzz)

  def show_languages
    @id = id
    current_display_name = storer.kata_exists?(id) ? katas[id].display_name : nil
    choices = starter.languages_choices(current_display_name)
    @major_names   = choices['major_names']
    @major_index   = choices['major_index']
    @minor_names   = choices['minor_names']
    @minor_indexes = choices['minor_indexes']
  end

  def show_exercises
    @language = params['language']
    @test = params['test']
    #@major = params['major] # TODO
    #@minor = params['minor] # TODO
    current_exercise_name = storer.kata_exists?(id) ? katas[id].exercise : nil
    choices = starter.exercises_choices(current_exercise_name)
    @exercises_names = choices['names']
    @exercises       = choices['contents']
    @initial_index   = choices['index']
  end

  def save
    major = params['major']
    minor = params['minor']
    exercise_name = params['exercise']
    manifest = starter.language_manifest(major, minor, exercise_name)
    kata = katas.create_kata(manifest)
    render json: {
      image_name: kata.image_name,
              id: kata.id,
       selection: major + ', ' + minor # TODO: used?
     }
  end

end
