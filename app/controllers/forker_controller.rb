require_relative '../../lib/time_now'

class ForkerController < ApplicationController

  def fork_individual
    fork { |manifest| saver.kata_create(manifest) }
  end

  def fork_group
    fork { |manifest| saver.group_create(manifest) }
  end

  private

  include TimeNow

  def fork
    begin
      manifest = kata.manifest.to_json
      manifest.delete('id')
      manifest['visible_files'] = kata.events[index].files
      manifest['created'] = time_now
      forked_id = yield(manifest)
      result = {
        forked: true,
            id: forked_id
      }
    rescue => caught
      result = fork_failed(caught)
    end
    respond_to do |format|
      format.json { render json: result }
    end
  end

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
