
class SetupCustomStartPointController < ApplicationController

  def show
    @id = id
    current_display_name = (id != nil && kata.exists?) ? kata.display_name : nil
    @custom_names = starter.custom_start_points
    @custom_index = index_match(@custom_names, current_display_name)
    @from = params['from']
  end

  def save_individual
    kata = kata_create
    avatar = kata.avatar_start
    redirect_to "/kata/edit/#{kata.id}?avatar=#{avatar.name}"
  end

  def save_group
    kata = kata_create
    redirect_to "/kata/group/#{kata.id}"
  end

  private

  def kata_create
    display_name = params['display_name']
    manifest = starter.custom_manifest(display_name)
    katas.kata_create(manifest)
  end

  def index_match(names, current_name)
    index = names.index(current_name)
    index ? index : rand(0...names.size)
  end

end
