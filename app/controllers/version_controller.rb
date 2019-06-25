
class VersionController < ApplicationController

  def index
    @dot_env = versioner.dot_env
    @start_points = {
      'custom'    => start_point('custom',    custom.sha),
      'exercises' => start_point('exercises', exercises.sha),
      'languages' => start_point('languages', languages.sha)
    }
    @services = {
      'differ'     => service('differ'),
      'grafana'    => service('grafana'),
      'mapper'     => service('mapper'),
      'nginx'      => service('nginx'),
      'prometheus' => service('prometheus'),
      'ragger'     => service('ragger'),
      'runner'     => service('runner'),
      'saver'      => service('saver'),
      'web'        => service('web'),
      # 'zipper'    => service('zipper')
    }
  end

  private

  def start_point(name, sha)
    key = "CYBER_DOJO_#{name.upcase}"
    { 'image_name' => @dot_env[key],
      'sha' => sha
    }
  end

  def service(name)
    key = "CYBER_DOJO_#{name.upcase}_SHA"
    sha = @dot_env[key]
    {
      'name' => name,
      'sha' => sha,
      'github_url' => github_url(name, sha)
    }
  end

  def github_url(repo_name, sha)
    "https://github.com/cyber-dojo/#{repo_name}/tree/#{sha}"
  end

end
