require_relative '../../lib/time_now'

class SetupDefaultStartPointController < ApplicationController

  def show
    @id = id
    current_display_name = (id != nil && kata.exists?) ? kata.manifest.display_name : nil
    current_exercise_name = (id != nil && kata.exists?) ? kata.manifest.exercise : nil

    @language_names = languages.start_points
    @language_index = index_match(@language_names, current_display_name)

    esp = exercises.start_points
    @exercise_names = esp.keys.sort
    @exercise_index = index_match(@exercise_names, current_exercise_name)
    @instructions = []
    @exercise_names.each do |name|
      @instructions << esp[name]['content']
    end
    @from = params['from']
  end

  def save_individual
    kata = katas.new_kata(starter_manifest)
    redirect_to "/kata/edit/#{kata.id}"
  end

  def save_group
    group = groups.new_group(starter_manifest)
    redirect_to "/kata/group/#{group.id}"
  end

  private

  include TimeNow

  def starter_manifest
    em = exercises.manifest(params['exercise'])
    manifest = languages.manifest(params['language'])
    manifest['visible_files'].merge!(em['visible_files'])
    manifest['created'] = time_now
    manifest
  end

  def index_match(names, current_name)
    index = names.index(current_name)
    index ? index : rand(0...names.size)
  end

end
