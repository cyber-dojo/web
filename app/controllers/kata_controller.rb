require_relative '../../lib/time_now'

class KataController < ApplicationController

  def group
    @id = id
  end

  def edit
    ported {
      @kata = katas[id]
      @title = 'test:' + @kata.id
    }
  end

  def run_tests
    # After a test-event completes if you refresh the
    # page in the browser then nothing will change.
    @kata = katas[id]

    stdout,stderr,status,
      @colour,
        files,@new_files,@deleted_files,@changed_files = @kata.run_tests(params)

    n = params[:tag].to_i
    @kata.ran_tests(n, files, time_now, stdout, stderr, status, @colour)

    @tag = n
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
