
class ImagePullerController < ApplicationController

  # From language+test setup page

  def language_pull_needed
    pull_needed(language.image_name)
  end

  def language_pull
    pull(language.image_name)
  end

  # From custom setup page

  def custom_pull_needed
    pull_needed(custom.image_name)
  end

  def custom_pull
    pull(custom.image_name)
  end

  # From fork page/dialog

  def kata_pull_needed
    pull_needed(kata.image_name)
  end

  def kata_pull
    pull(kata.image_name)
  end

  private

  def pull_needed(image_name)
    render json: { needed: !dojo.runner.pulled?(image_name) }
  end

  def pull(image_name)
    _output, exit_status = dojo.runner.pull(image_name)
    render json: { succeeded: exit_status == 0 }
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
