
class ErrorController < ApplicationController

  def render_404
    respond_to do |format|
      format.html { render template: 'error/404', layout: 'layouts/raw', status: 404 }
      format.all { render nothing: true, status: 404 }
    end
  end

  def render_500
    respond_to do |format|
      format.html { render template: 'error/500', layout: 'layouts/raw', status: 500 }
      format.all { render nothing: true, status: 500 }
    end
  end

end
