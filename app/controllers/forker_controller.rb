
class ForkerController < ApplicationController

  def fork_individual
    json = fork { |manifest| model.kata_create(manifest) }
    respond_to { |format|
      format.html { redirect_to "/creator/enter?id=#{json[:id]}" }
      format.json { render json:json }
    }
  end

  def fork_group
    json = fork { |manifest| model.group_create(manifest) }
    respond_to { |format|
      format.html { redirect_to "/creator/enter?id=#{json[:id]}" }
      format.json { render json:json }
    }
  end

  private

  def manifest_at_index
    id = params[:id]
    index = params[:index]
    manifest = model.kata_manifest(id)
    files = model.kata_event(id, index)['files']
    manifest.merge({ 'visible_files' => files })
  end

  def fork
    { forked: true,
          id: yield(manifest_at_index)
    }
  rescue => caught
    {  forked: false,
      message: caught.message
    }
  end

end
