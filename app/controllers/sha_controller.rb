
class ShaController < ApplicationController

  def index
    @shas = {
      'web' => web_sha,
      'starter' => starter.sha,
      'saver' => saver.sha,
      'runner-stateless' => runner.sha('stateless'),
      'runner-stateful' => runner.sha('stateful'),
      'differ' => differ.sha,
      'zipper' => zipper.sha,
      'porter' => porter.sha
    }
  end

  private

  def web_sha
    IO.read('/cyber-dojo/sha.txt').strip
  end

end
