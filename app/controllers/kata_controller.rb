require_relative '../../lib/time_now'

class KataController < ApplicationController

  def group
    @id = id
  end

  def edit
    ported {
      @kata = kata
      @title = 'test:' + @kata.id
      @index = @kata.events.last.index
    }
  end

  def run_tests
    # After a test-event completes if you refresh the
    # page in the browser then nothing will change.

    # @new_files,@deleted_files,@changed_files
    #   o) have already been set in files ready to be saved.
    #   o) need to be updated in the browser.
    @stdout,@stderr,@status,
      colour,
        files,@new_files,@deleted_files,@changed_files = kata.run_tests(params)

    index = params[:index].to_i + 1
    t1 = time_now
    kata.ran_tests(index, files, t1, @stdout, @stderr, @status, colour)

    @light = Event.new(self, kata, { 'time' => t1, 'colour' => colour }, index)
    @id = kata.id

    respond_to do |format|
      format.js   { render layout: false }
      format.json { show_json }
    end
  end

  def show_json
    # https://atom.io/packages/cyber-dojo
    render :json => {
      'visible_files' => kata.files,
             'avatar' => kata.avatar_name,
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
      'index'  => light.index
    }
  end

end
