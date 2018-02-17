
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

  def save
    major = params['major']
    minor = params['minor']
    manifest = starter.custom_manifest(major, minor)
    kata = katas.create_kata(manifest)
    redirect_to "/kata/group/#{kata.id}"
  end

  private

  include DisplayNameIndexer

end
