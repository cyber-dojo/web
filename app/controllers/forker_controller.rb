
class ForkerController < ApplicationController

  def fork
    begin
      tag_visible_files = storer.tag_visible_files(id, avatar_name, tag)
      manifest = kata.fork(tag_visible_files)
      result = {
              forked: true,
                  id: manifest['id'],
          image_name: manifest['image_name'],
        display_name: manifest['display_name']
      }
    rescue => caught
      result = fork_failed(caught)
    end

    respond_to do |format|
      format.json { render json: result }
      format.html { redirect_to controller: 'enter',
                                    action: 'show',
                                        id: result[:id] }
    end
  end

  private # = = = = = = = = = = =

  def fork_failed(caught)
    result = { forked: false }
    if caught.message == 'invalid kata_id'
      result[:reason] = "dojo(#{id})"
    end
    if caught.message == 'invalid avatar_name'
      result[:reason] = "avatar(#{avatar_name})"
    end
    if caught.message == 'invalid tag'
      result[:reason] = "traffic_light(#{tag})"
    end
    result
  end

end

