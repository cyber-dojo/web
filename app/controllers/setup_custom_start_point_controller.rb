
class SetupCustomStartPointController < ApplicationController

  def show
    choices = starter.custom_choices
    current_display_name = kata.exists? ? kata.display_name : nil
    display_name_index(choices, current_display_name)
    @id = id
    @major_names   = choices['major_names']
    @major_index   = choices['major_index']
    @minor_names   = choices['minor_names']
    @minor_indexes = choices['minor_indexes']
    @from = params['from']
  end

  def save_individual
    major = params['major']
    minor = params['minor']
    manifest = starter.custom_manifest(major, minor)
    kata = katas.create_kata(manifest)
    avatar = kata.start_avatar
    redirect_to "/kata/individual/#{kata.id}?avatar=#{avatar.name}&from=individual"
  end

  def save_group
    major = params['major']
    minor = params['minor']
    manifest = starter.custom_manifest(major, minor)
    kata = katas.create_kata(manifest)
    redirect_to "/kata/group/#{kata.id}?from=group"
  end

  private

  include DisplayNameIndexer

end
