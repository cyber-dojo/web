
class ImagePullerController < ApplicationController

  # From language+test setup page

  def language_pull_needed
    render json: { needed: !dojo.runner.pulled?(language.image_name) }
  end

  def language_pull
    _output, exit_status = dojo.runner.pull(language.image_name)
    render json: { succeeded: exit_status == 0 }
  end

  # From custom setup page

  def custom_pull_needed
    render json: { needed: !dojo.runner.pulled?(custom.image_name) }
  end

  def custom_pull
    _output, exit_status = dojo.runner.pull(custom.image_name)
    render json: { succeeded: exit_status == 0 }
  end

  # From fork page/dialog

  def kata_pull_needed
    render json: { needed: !dojo.runner.pulled?(kata.image_name) }
  end

  def kata_pull
    _output, exit_status = dojo.runner.pull(kata.image_name)
    render json: { succeeded: exit_status == 0 }
  end

  private

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
