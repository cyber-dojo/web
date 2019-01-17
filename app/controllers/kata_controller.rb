require_relative '../../lib/time_now'

class KataController < ApplicationController

  def group
    @id = id
  end

  def edit
    mapped {
      @title = 'kata:' + kata.id
      @files = kata.files(:with_output)
    }
  end

  def run_tests
    t1 = time_now

    @stdout,@stderr,@status,colour,
      files,@created,@deleted,@changed = kata.run_tests(params)

    t2 = time_now
    duration = Time.mktime(*t2) - Time.mktime(*t1)
    index = params[:index].to_i + 1
    kata.ran_tests(index, files, t1, duration, @stdout, @stderr, @status, colour)

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
