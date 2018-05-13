
class ShaController < ApplicationController

  def show
    @shas = {
      'starter' => starter.sha,
      #'storer' => storer.sha
      #'runner-stateless' => runner.sha('stateless'),
      #'runner-stateful' => runner.sha('stateful'),
    }
  end

end
