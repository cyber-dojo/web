
class ForkerController < ApplicationController

  def fork_individual
    json = fork { |manifest| model.kata_create(manifest) }
    respond_in_format(json)
  end

  def fork_group
    json = fork { |manifest| model.group_create(manifest) }
    respond_in_format(json)
  end

  private

  def manifest_at_index
    manifest = model.kata_manifest(id)
    files = model.kata_event(id, index)['files']
    manifest.merge({ 'visible_files' => files })
  end

  def fork
    {     id: yield(manifest_at_index),
      forked: true
    }
  rescue => caught
    { message: caught.message,
       forked: false,      
    }
  end

  def respond_in_format(json)
    respond_to { |format|
      format.html { redirect_to "/creator/enter?id=#{json[:id]}" }
      format.json { render json:json }
    }
  end

end
