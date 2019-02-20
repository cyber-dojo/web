
class ShaController < ApplicationController

  def index
    @shas = {
      'web'     => web_sha,
      # 'starter' => starter.sha, # different. Hmmm....
      'saver'   => saver.sha,
      'mapper'  => mapper.sha,
      'runner-stateless' => runner.sha,
      'differ'  => differ.sha,
      #'zipper'  => zipper.sha, # Offline
    }
  end

  private

  def web_sha
    ENV['SHA']
  end

end
