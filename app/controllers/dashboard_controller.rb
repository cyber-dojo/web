
class DashboardController < ApplicationController

  protect_from_forgery except: :heartbeat

  def show
    gather
    @title = 'dashboard:' + group.id
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
