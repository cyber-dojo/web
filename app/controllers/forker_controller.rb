
class ForkerController < ApplicationController

  def fork_individual
    json = do_fork { |manifest| katas.new_kata(manifest) }
    respond_to do |format|
      format.html { redirect_to "/kata/edit/#{json[:id]}" }
      format.json { render json:json }
    end
  end

  def fork_group
    json = do_fork { |manifest| groups.new_group(manifest) }
    respond_to do |format|
      format.html { redirect_to "/kata/group/#{json[:id]}" }
      format.json { render json:json }
    end
  end

  def fork
    # See https://blog.cyber-dojo.org/2014/08/custom-starting-point.html
    manifest = kata.events[index].manifest
    manifest['created'] = time.now
    group = groups.new_group(manifest)
    respond_to do |format|
      format.html {
        redirect_to "/kata/group/#{group.id}"
      }
    end
  end

  private

  def do_fork
    begin
      manifest = kata.events[index].manifest
      manifest['version'] = 1
      manifest['created'] = time.now
      forked = yield(manifest)
      {
        forked: true,
            id: forked.id
      }
    rescue => caught
      {
         forked: false,
        message: caught.message
      }
    end
  end

end
