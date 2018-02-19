
class SetupCustomStartPointController < ApplicationController

  def show
    start_points = starter.custom_start_points
    @id = id
    @custom_names = start_points
    @custom_index = 1 # TODO
    #choices = starter.custom_choices
    #current_display_name = kata.exists? ? kata.display_name : nil
    #display_name_index(choices, current_display_name)
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

  include DisplayNameIndexer

  def create_kata
    display_name = params['display_name']
    manifest = starter.custom_manifest(display_name)
    katas.create_kata(manifest)
  end

end
