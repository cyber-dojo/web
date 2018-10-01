
class ShaController < ApplicationController

  def index
    @shas = {
      #'differ' => differ.sha,
      #'starter' => starter.sha,
      #'grouper' => grouper.sha,
      #'singler' => singler.sha,
      'web' => web_sha,
      #'zipper' => zipper.sha,
      #'runner-stateless' => runner.sha('stateless'),
      #'runner-stateful' => runner.sha('stateful'),
    }
  end

  private

  def web_sha
    IO.read('/cyber-dojo/sha.txt').strip
  end

end
