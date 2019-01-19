require_relative '../../lib/time_now'

class ForkerController < ApplicationController

  def fork_individual
    fork { |manifest|
      saver.kata_create(manifest)
    }
  end

  def fork_group
    fork { |manifest|
      saver.group_create(manifest)
    }
  end

  private

  include TimeNow

  def fork
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
      #format.html { # See
        # https://blog.cyber-dojo.org/2014/08/custom-starting-point.html
      #  redirect_to "/kata/edit/#{result[:id]}"
      #}
    end
  end

end
