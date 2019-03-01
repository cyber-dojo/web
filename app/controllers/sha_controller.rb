
class ShaController < ApplicationController

  def index
    @services = {
      'differ'  => triple('differ', differ.sha),
      'mapper'  => triple('mapper', mapper.sha),
      'runner'  => triple('runner', runner.sha, github_url('runner-stateless', runner.sha)),
      'saver'   => triple('saver', saver.sha),
      'starter' => triple('starter', starter.sha, github_url('start-points-base', starter.sha)),
      'web'     => triple('web', web_sha),
      # 'zipper'  => triple('zipper', zipper.sha)
    }
  end

  private

  def web_sha
    ENV['SHA']
  end

  def triple(name, sha, url = github_url(name, sha))
    { 'name' => name, 'sha' => sha, 'github_url' => url }
  end

  def github_url(repo_name, sha)
    "https://github.com/cyber-dojo/#{repo_name}/tree/#{sha}"
  end

end
