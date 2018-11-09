require_relative '../../lib/phonetic_alphabet'
require_relative '../../lib/time_now'

class ForkerController < ApplicationController

  def fork_individual
    begin
      manifest = kata.manifest.to_json
      manifest.delete('id')
      manifest['visible_files'] = kata.events[index].files
      manifest['created'] = time_now

      forked_id = saver.kata_create(manifest)
      result = {
        forked: true,
        id: forked_id
        #phonetic: Phonetic.spelling(forked_id[0..5]).join('-')
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
      when -> (msg) { msg.include? 'id' }
        result[:reason] = "kata(#{id})"
      when -> (msg) { msg.include? 'index' }
        result[:reason] = "event(#{index})"
      else
        raise caught
    end
    result
  end

end
