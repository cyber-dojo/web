
class SetupCustomStartPointController < ApplicationController

  def show
    @id = id
    current_display_name = kata.exists? ? kata.display_name : nil
    @custom_names = starter.custom_start_points
    @custom_index = index_match(@custom_names, current_display_name)
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
    display_name = params['display_name']
    manifest = starter.custom_manifest(display_name)
    katas.create_kata(manifest)
  end

  def index_match(names, current_name)
    index = names.index(current_name)
    index ? index : rand(0...names.size)
  end

end
