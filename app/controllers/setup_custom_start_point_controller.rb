require_relative '../../lib/time_now'

class SetupCustomStartPointController < ApplicationController

  def show
    @id = id
    @custom_names = custom.names
    @custom_index = random_index(@custom_names)
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

  def random_index(names)
    rand(0...names.size)
  end

end
