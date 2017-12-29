
class SetupCustomStartPointController < ApplicationController

  # Custom exercise (one-step setup)

  def show
    choices = starter.custom_choices
    current_display_name = kata.exists? ? kata.display_name : nil
    display_name_index(choices, current_display_name)
    @id = id
    @major_names   = choices['major_names']
    @major_index   = choices['major_index']
    @minor_names   = choices['minor_names']
    @minor_indexes = choices['minor_indexes']
  end

  def save
    major = params['major']
    minor = params['minor']
    manifest = starter.custom_manifest(major, minor)
    kata = katas.create_kata(manifest)
    render json: {
        image_name: kata.image_name,
                id: kata.id,
      display_name: kata.display_name
    }
  end

  private

  include DisplayNameIndexer

end
