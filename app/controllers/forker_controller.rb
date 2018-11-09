require_relative '../../lib/phonetic_alphabet'
require_relative '../../lib/time_now'

class ForkerController < ApplicationController

  def fork
    begin
      forked_id = storer.tag_fork(id, index, time_now)
      result = {
        forked: true,
        id: forked_id,
        phonetic: Phonetic.spelling(forked_id[0..5]).join('-')
      }
    rescue => caught
      result = fork_failed(caught)
    end

    respond_to do |format|
      format.json { render json: result }
      format.html { redirect_to controller: 'kata',
                                    action: 'group',
                                        id: result[:id] }
    end
  end

  private # = = = = = = = = = = =

  include TimeNow

  def fork_failed(caught)
    result = { forked: false }
    case caught.message
      when -> (msg) { msg.include? 'kata_id' }
        result[:reason] = "dojo(#{id})"
      when -> (msg) { msg.include? 'tag' }
        result[:reason] = "traffic_light(#{params['tag']})"
      else
        raise caught
    end
    result
  end

end
