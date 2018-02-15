
class SetupDefaultStartPointController < ApplicationController

  def show
    sp = starter.languages_exercises_start_points
    @id = id
    @languages_names = sp['languages'].sort
    @language_index = 0 # TODO
    #current_display_name = kata.exists? ? kata.display_name : nil
    #display_name_index(choices, current_display_name)

    @exercises_names = sp['exercises'].keys.sort
    @exercise_index = 0 # TODO
    #current_exercise_name = kata.exists? ? kata.exercise : nil
    #exercise_index(choices, current_exercise_name)

    @from = params['from']
  end

  def save_individual
    language = params['language']
    exercise = params['exercise']
    # TODO: what if the exercise is '(Verbal)'
    manifest = starter.language_exercise_manifest(language, exercise)
    kata = katas.create_kata(manifest)
    avatar = kata.start_avatar
    @kata_id = kata.id
    @avatar_name = avatar.name
  end

  private

  #include DisplayNameIndexer

  #def exercise_index(choices, current_exercise_name)
  #  names = choices['names']
  #  index = names.index(current_exercise_name)
  #  choices['index'] = index ? index : rand(0...names.size)
  #end

end
