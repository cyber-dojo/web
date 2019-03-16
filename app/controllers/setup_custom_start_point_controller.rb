require_relative '../../lib/time_now'

class SetupCustomStartPointController < ApplicationController

  def show
    @id = id
    current_display_name = (id != nil && kata.exists?) ? kata.manifest.display_name : nil
    @custom_names = custom.names
    @custom_index = index_match(@custom_names, current_display_name)
    @from = params['from']
  end

  def save_individual
    kata = katas.new_kata(starter_manifest)
    redirect_to "/kata/edit/#{kata.id}"
  end

  def save_group
    group = groups.new_group(starter_manifest)
    redirect_to "/kata/group/#{group.id}"
  end

  private

  include TimeNow

  def starter_manifest
    name = params['display_name']
    manifest = custom.manifest(name)
    manifest['created'] = time_now
    manifest
  end

  def index_match(names, current_name)
    index = names.index(current_name)
    index ? index : rand(0...names.size)
  end

end
