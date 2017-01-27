
class ImagePullerController < ApplicationController

  def pull_needed
    render json: { needed: !runner.pulled?(image_name) }
  end

  def pull
    render json: { succeeded: runner.pull(image_name) }
  end

  private

  def image_name
    # From language+test setup page
    return language.image_name if type_is? 'language'
    # From custom setup page
    return   custom.image_name if type_is? 'custom'
    # From fork page/dialog
    return     kata.image_name if type_is? 'kata'
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

  def type_is?(name)
    params['type'] == name
  end

end
