
class ForkerController < ApplicationController

  def fork
    result = { forked: false }
    error = false

    if !error && kata.nil?
      error = true
      result[:reason] = "dojo(#{id})"
    end

    if !error && avatar.nil?
      error = true
      result[:reason] = "avatar(#{avatar_name})"
    end

    #tag = avatar.tags[params['tag']]
    if !error # && !light.exists?
      is_tag = params['tag'].match(/^\d+$/)
      tag = params['tag'];
      if !is_tag || tag.to_i <= 0 || tag.to_i > avatar.lights.count
        error = true
        result[:reason] = "traffic_light(#{tag})"
      end
    end

    if !error
      tag = params['tag'].to_i
      manifest = {
                         id: unique_id,
                    created: time_now,
                 image_name: kata.image_name,
                   language: kata.language,
                   exercise: kata.exercise,
                   tab_size: kata.tab_size,
              visible_files: avatar.tags[tag].visible_files
      }

      # before or after start-points volume re-architecture?
      if !kata.unit_test_framework.nil?
        # before
        manifest[:unit_test_framework] = kata.unit_test_framework
      else
        # after
        lambda_src = kata.red_amber_green(nil)
        manifest[:red_amber_green] = lambda_src
      end

      forked_kata = katas.create_kata_from_kata_manifest(manifest)

      result[:forked] = true
      result[:id] = forked_kata.id
    end

    respond_to do |format|
      format.json { render json: result }
      format.html { redirect_to controller: 'enter',
                                    action: 'show',
                                        id: result[:id] }
    end
  end

  private

  include TimeNow
  include UniqueId

end

