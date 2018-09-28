require_relative '../../lib/time_now'

class SetupCustomStartPointController < ApplicationController

  def show
    @id = id
    current_display_name = (id != nil && kata.exists?) ? kata.display_name : nil
    @custom_names = starter.custom_start_points
    @custom_index = index_match(@custom_names, current_display_name)
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
    display_name = params['display_name']
    manifest = starter.custom_manifest(display_name)
    manifest['created'] = time_now
    files = manifest.delete('visible_files')
    [manifest,files]
  end

  def index_match(names, current_name)
    index = names.index(current_name)
    index ? index : rand(0...names.size)
  end

end
