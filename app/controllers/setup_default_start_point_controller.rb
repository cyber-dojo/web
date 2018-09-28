require_relative '../../lib/time_now'

class SetupDefaultStartPointController < ApplicationController

  def show
    @id = id
    current_display_name = (id != nil && kata.exists?) ? kata.display_name : nil
    current_exercise_name = (id != nil && kata.exists?) ? kata.exercise : nil
    start_points = starter.language_start_points
    @language_names = start_points['languages']
    @language_index = index_match(@language_names, current_display_name)
    @exercise_names = start_points['exercises'].keys.sort
    @exercise_index = index_match(@exercise_names, current_exercise_name)
    @instructions = []
    @exercise_names.each do |name|
      @instructions << start_points['exercises'][name]
    end
    @from = params['from']
  end

  def save_individual
    manifest,files = from_starter
    kata = katas.new_kata(manifest, files)
    redirect_to "/kata/edit/#{kata.id}"
  end

  def save_group
    manifest,files = from_starter
    group = groups.new_group(manifest, files)
    redirect_to "/kata/group/#{group.id}"
  end

  private

  include TimeNow

  def from_starter
    language = params['language']
    exercise = params['exercise']
    manifest = starter.language_manifest(language, exercise)
    manifest['created'] = time_now
    files = manifest.delete('visible_files')
    return [manifest,files]
  end

  def index_match(names, current_name)
    index = names.index(current_name)
    index ? index : rand(0...names.size)
  end

end
