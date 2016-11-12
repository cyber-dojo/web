
class SetupCustomStartPointController < ApplicationController

  # Custom exercise (one-step setup)

  def show
    @id = id
    @title = 'create'
    custom_names = display_names_of(dojo.custom)
    index = choose_language(custom_names, dojo.katas[id])
    @start_points = ::DisplayNamesSplitter.new(custom_names, index)
  end

  def save
    manifest = custom.create_kata_manifest
    katas.create_kata(manifest)
    runner.new_kata(manifest[:image_name], manifest[:id])
    render json: { id: manifest[:id] }
  end

  private

  include StartPointChooser

  def display_names_of(start_points)
    start_points.map(&:display_name).sort
  end

  def custom
    dojo.custom[params['major'] + '-' + params['minor']]
  end

end
