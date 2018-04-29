
class ShaController < ApplicationController

  def show
    @shas = {
      'starter' => starter.sha,
      'storer' => storer.sha
    }
  end

end
