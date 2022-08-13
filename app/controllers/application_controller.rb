require_relative '../services/externals'
require 'json'

class ApplicationController < ActionController::Base

  protect_from_forgery

  include Externals

  unless Rails.application.config.consider_all_requests_local
    rescue_from Exception, with: :render_500
  end

  def render_500(exception)
    respond_to do |format|
      format.html { render template: 'error/500', layout: 'layouts/raw', status: 500 }
      format.all { render nothing: true, status: 500}
    end
  end

end
