
class SetupCustomStartPointController < ApplicationController

  def show
    @id = id
    @custom_names = custom_start_points.names
    @custom_index = random_index(@custom_names)
    @from = params['from']
  end

  def save_individual
    manifest = starter_manifest
    kata = katas.new_kata(manifest) # TODO: rescue SaverService::Error
    respond_to do |format|
      format.html { redirect_to "/kata/edit/#{kata.id}" }
    end
  end

  def save_group
    manifest = starter_manifest
    group = groups.new_group(manifest)
    respond_to do |format|
      format.html { redirect_to "/kata/group/#{group.id}" }
    end
  end

  # - - - - - - - - - - - - - - - - - - - - -

  def save_individual_json
    manifest = starter_manifest
    kata = katas.new_kata(manifest)
    respond_to do |format|
      format.json { render json:{id:kata.id} }
    end
  end

  def save_group_json
    manifest = starter_manifest
    group = groups.new_group(manifest)
    respond_to do |format|
      format.json { render json:{id:group.id} }
    end
  end

  private

  def starter_manifest
    name = params['display_name']
    manifest = custom_start_points.manifest(name)
    manifest['created'] = time.now
    manifest['version'] = 1
    manifest
  end

  def random_index(names)
    rand(0...names.size)
  end

end
