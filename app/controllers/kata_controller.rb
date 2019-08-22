require_relative '../../lib/time_now'

class KataController < ApplicationController

  def group
    @id = id
  end

  def edit
    mapped_id {
      @title = 'kata:' + kata.id
      @manifest = kata.manifest
      @files = kata.files(:with_output)
    }
  end

  def run_tests
    t1 = time_now

    result,files,@created,@deleted,@changed = kata.run_tests(params)
    @stdout = result['stdout']
    @stderr = result['stderr']
    @status = result['status']

    if result['timed_out']
      colour = 'timed_out'
    else
      args = [params['image_name'], kata.id]
      args += [@stdout['content'], @stderr['content'], @status.to_i]
      begin
        colour = ragger.colour(*args)
      rescue RaggerException
        colour = 'faulty'
        # TODO: @message on footer...
      end
    end

    t2 = time_now
    duration = Time.mktime(*t2) - Time.mktime(*t1)
    index = params[:index].to_i + 1
    # [1] The saver service does not yet know about
    # the new 'faulty' traffic-light colour.
    args = []
    args << index                       # index of traffic-light event
    args << files                       # including @created,@deleted,@changed
    args += [t1,duration]               # how long runner+ragger took
    args += [@stdout, @stderr, @status] # output of [test] kata.run_tests()
    args << ((colour === 'faulty') ? 'amber' : colour) # [1]
    begin
      kata.ran_tests(*args)
    rescue SaverException
      #TODO: @message on footer...
    end

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
