
class ShaController < ApplicationController

  def index
    @shas = {
      'starter' => starter.sha,
      'storer' => storer.sha,
      'web' => web_sha,
      'zipper' => zipper.sha,
      #'runner-stateless' => runner.sha('stateless'),
      #'runner-stateful' => runner.sha('stateful')
    }
  end

  private

  def web_sha
    IO.read('/cyber-dojo/sha.txt').strip
  end

end
