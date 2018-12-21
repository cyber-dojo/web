
class ShaController < ApplicationController

  def index
    @shas = {
      'web'     => web_sha,
      'starter' => starter.sha,
      'saver'   => saver.sha,
      #'runner'  => runner.sha,
      'differ'  => differ.sha,
      #'zipper'  => zipper.sha,
    }
  end

  private

  def web_sha
    ENV['SHA']
  end

end
