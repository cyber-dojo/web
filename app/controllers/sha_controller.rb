
class ShaController < ApplicationController

  def index
    @shas = {
      'web'     => web_sha,
      #'starter' => starter.sha,
      'saver'   => saver.sha,
      'runner'  => runner.sha,
      #'differ'  => differ.sha,
      #'zipper'  => zipper.sha,
    }
  end

  private

  def web_sha
    IO.read('/cyber-dojo/sha.txt').strip
  end

end
