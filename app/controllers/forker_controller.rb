
class ForkerController < ApplicationController

  def fork_individual
    json = do_fork { |manifest|
      model.kata_create(manifest)
    }
    respond_to do |format|
      format.html { redirect_to "/kata/edit/#{json[:id]}" } # TODO change URL
      format.json { render json:json }
    end
  end

  def fork_group
    json = do_fork { |manifest|
      model.group_create(manifest)
    }
    respond_to do |format|
      format.html { redirect_to "/kata/group/#{json[:id]}" } # TODO: change URL
      format.json { render json:json }
    end
  end

  private

  def manifest_at_index
    id = params[:id]
    index = params[:index]
    manifest = model.kata_manifest(id)
    files = model.kata_event(id, index)['files']
    manifest.merge({ 'visible_files' => files })
  end

  def do_fork
    begin
      { forked: true,
            id: yield(manifest_at_index)
      }
    rescue => caught
      {  forked: false,
        message: caught.message
      }
    end
  end

end
