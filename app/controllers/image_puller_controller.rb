
class ImagePullerController < ApplicationController

  def pull_needed
    render json: { needed: !runner.pulled?(image_name) }
  end

  def pull
    _stdout,_stderr,status = runner.pull(image_name)
    render json: { succeeded: status == 0 }
  end

  private

  def image_name
    return language.image_name if params['type'] == 'language'  # From language+test setup page
    return   custom.image_name if params['type'] == 'custom'    # From custom setup page
    return     kata.image_name if params['type'] == 'kata'      # From fork page/dialog
  end

  def language
    dojo.languages[params['major'] + '-' + params['minor']]
  end

  def custom
    dojo.custom[params['major'] + '-' + params['minor']]
  end

  def kata
    dojo.katas[params['id']]
  end

end
