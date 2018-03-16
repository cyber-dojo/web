require_relative '../../lib/time_now'

class ForkerController < ApplicationController

  def fork
    begin
      forked_id = storer.tag_fork(id, avatar_name, tag, time_now)
      result = { forked:true, id:forked_id }
    rescue => caught
      result = fork_failed(caught)
    end

    respond_to do |format|
      format.json { render json: result }
      format.html { redirect_to controller: 'kata',
                                    action: 'individual',
                                        id: result[:id] }
    end
  end

  private # = = = = = = = = = = =

  include TimeNow

  def fork_failed(caught)
    result = { forked: false }
    case caught.message
      when -> (msg) { msg.end_with? 'invalid kata_id' }
        result[:reason] = "dojo(#{id})"
      when -> (msg) { msg.end_with? 'invalid avatar_name' }
        result[:reason] = "avatar(#{avatar_name})"
      when -> (msg) { msg.end_with? 'invalid tag' }
        result[:reason] = "traffic_light(#{tag})"
      else
        raise caught
    end
    result
  end

end

