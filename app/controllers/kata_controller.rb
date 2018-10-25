require_relative '../../lib/time_now'

class KataController < ApplicationController

  def group
    @id = id
  end

  def edit
    ported {
      @kata = kata
      @title = 'test:' + @kata.id
      @tag = @kata.events.last.number
    }
  end

  def run_tests
    # After a test-event completes if you refresh the
    # page in the browser then nothing will change.
    @kata = kata

    # @new_files,@deleted_files,@changed_files
    #   o) have already been set in files ready to be saved.
    #   o) need to be updated in the browser.
    @stdout,@stderr,status,
      @colour,
        files,@new_files,@deleted_files,@changed_files = @kata.run_tests(params)

    @tag = params[:tag].to_i + 1

    @kata.ran_tests(@tag, files, time_now, @stdout, @stderr, status, @colour)

    respond_to do |format|
      format.js   { render layout: false }
      format.json { show_json }
    end
  end

  def show_json
    # https://atom.io/packages/cyber-dojo
    render :json => {
      'visible_files' => kata.files,
             'avatar' => avatar_name,
         'csrf_token' => form_authenticity_token,
             'lights' => kata.lights.map { |light| to_json(light) }
    }
  end

  private

  include TimeNow

  def to_json(light)
    {
      'colour' => light.colour,
      'time'   => light.time,
      'number' => light.number
    }
  end

end
