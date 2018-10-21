
class DashboardController < ApplicationController

  protect_from_forgery except: :heartbeat

  def show
    if id.size == 10
      redirect_to request.url.sub(id, porter.port(id))
    else
      gather
      @title = 'dashboard:' + partial(@group.id)
    end
  end

  def heartbeat
    gather
    respond_to { |format| format.js }
  end

  def progress
    render json: { animals: animals_progress }
  end

  private

  include DashboardWorker

end
