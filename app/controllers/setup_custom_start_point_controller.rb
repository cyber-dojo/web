
class SetupCustomStartPointController < ApplicationController

  # Custom exercise (one-step setup)

  def show
    @id = id
    @title = 'create'
    custom_names = display_names_of(dojo.custom)
    kata = (id != nil) ? dojo.katas[id] : nil
    index = choose_language(custom_names, kata)
    @start_points = ::DisplayNamesSplitter.new(custom_names, index)
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

  include StartPointChooser

  def display_names_of(start_points)
    start_points.map(&:display_name).sort
  end

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
