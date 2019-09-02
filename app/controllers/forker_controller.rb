require_relative '../../lib/time_now'

class ForkerController < ApplicationController

  def fork_individual
    fork_json { |manifest|
      katas.new_kata(manifest)
    }
  end

  def fork_group
    fork_json { |manifest|
      groups.new_group(manifest)
    }
  end

  def fork
    # See https://blog.cyber-dojo.org/2014/08/custom-starting-point.html
    mapped_id {
      manifest = kata.events[index].manifest
      manifest['created'] = time_now
      gid = groups.new_group(manifest)
      respond_to do |format|
        format.html {
          redirect_to "/kata/group/#{gid}"
        }
      end
    }
  end

  private

  include TimeNow

  def fork_json
    begin
      manifest = kata.events[index].manifest
      manifest['created'] = time_now
      forked_id = yield(manifest)
      result = {
        forked: true,
            id: forked_id
      }
    rescue => caught
      result = {
         forked: false,
        message: caught.message
      }
    end
    respond_to do |format|
      format.json {
        render json: result
      }
    end
  end

end
