
class SetupCustomStartPointController < ApplicationController

  # Custom exercise (one-step setup)

  def show
    current_display_name = storer.kata_exists?(id) ? dojo.katas[id].display_name : nil
    choices = starter.custom_choices(current_display_name)
    @id = id
    @major_names   = choices['major_names']
    @major_index   = choices['major_index']
    @minor_names   = choices['minor_names']
    @minor_indexes = choices['minor_indexes']
  end

  def save
    manifest = custom.create_kata_manifest
    kata = katas.create_kata(manifest)
    render json: {
          image_name: kata.image_name,
                  id: kata.id,
           selection: major + ', ' + minor
    }
  end

  private

  def custom
    dojo.custom[major + '-' + minor]
  end

  def major
    params['major']
  end

  def minor
    params['minor']
  end

end
