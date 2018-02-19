
class SetupDefaultStartPointController < ApplicationController

  def show
    start_points = starter.language_start_points
    @id = id
    @languages_names = start_points['languages']
    @language_index = 1 # TODO
    #current_display_name = kata.exists? ? kata.display_name : nil
    #display_name_index(choices, current_display_name)

    @exercises_names = start_points['exercises'].keys.sort
    @exercise_index = 1 # TODO
    #current_exercise_name = kata.exists? ? kata.exercise : nil
    #exercise_index(choices, current_exercise_name)
    @instructions = []
    @exercises_names.each do |name|
      @instructions << start_points['exercises'][name]
    end
    @from = params['from']
  end

  def save_individual
    kata = create_kata
    avatar = kata.start_avatar
    redirect_to "/kata/individual/#{kata.id}?avatar=#{avatar.name}"
  end

  def save_group
    kata = create_kata
    redirect_to "/kata/group/#{kata.id}"
  end

  private

  def create_kata
    language = params['language']
    exercise = params['exercise']
    start_point = starter.language_manifest(language, exercise)
    instructions = start_point['exercise']
    manifest = start_point['manifest']
    manifest['exercise'] = exercise
    manifest['visible_files']['instruction'] = instructions
    manifest
    katas.create_kata(manifest)
  end

  #include DisplayNameIndexer

  #def exercise_index(choices, current_exercise_name)
  #  names = choices['names']
  #  index = names.index(current_exercise_name)
  #  choices['index'] = index ? index : rand(0...names.size)
  #end

end
