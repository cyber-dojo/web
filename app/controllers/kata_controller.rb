
class KataController < ApplicationController

  def edit
    # who
    @id = kata.id
    @group_id = kata.group.id
    @avatar_index = kata.avatar_index
    @version = kata.schema.version
    if @group_id.nil?
      @title = @id
    else
      @title = "#{@group_id}"
    end
    # what
    manifest = kata.manifest
    @display_name = manifest.display_name
    @exercise = manifest.exercise
    # previous traffic-light-lights
    @events_json = kata.events_json
    @index = kata.events.last.index
    @lights = kata.lights
    # most recent files
    @files = kata.files
    @stdout = kata.stdout['content']
    @stderr = kata.stderr['content']
    @status = kata.status
    # parameters
    @image_name = manifest.image_name
    @filename_extension = manifest.filename_extension
    @highlight_filenames = manifest.highlight_filenames
    @max_seconds = manifest.max_seconds
    @tab_size = manifest.tab_size
    # settings
    @theme = kata.theme
    @colour = kata.colour
    @predict = kata.predict
    @env = ENV
  end

  # - - - - - - - - - - - - - - - - - -

  def set_colour
    kata.colour = params['value']
  end

  def set_theme
    kata.theme = params['value']
  end

  def set_predict
    kata.predict = params['value']
  end

  # - - - - - - - - - - - - - - - - - -

  def run_tests
    t1 = time.now
    result,files,@created,@deleted,@changed = kata.run_tests
    t2 = time.now

    duration = Time.mktime(*t2) - Time.mktime(*t1)
    predicted = params['predicted']
    @id = kata.id
    @index = params[:index].to_i + 1
    @avatar_index = params[:avatar_index]
    @stdout = result['stdout']
    @stderr = result['stderr']
    @status = result['status']
    @log = result['log']
    @outcome = result['outcome']
    @light = {
      'index' => @index,
      'time' => t1,
      'colour' => @outcome,
      'predicted' => predicted,
    }

    @out_of_sync = false
    begin
      model.kata_ran_tests(@id, @index, files, @stdout, @stderr, @status, {
        'duration' => duration,
        'colour' => @outcome,
        'predicted' => predicted
      })
    rescue ModelService::Error => error
      if model.kata_exists?(@id)
        @out_of_sync = true
        $stdout.puts(error.message);
        $stdout.flush
      else
        raise
      end
    end

    respond_to do |format|
      format.js   { render layout:false }
      format.json { show_json }
    end
  end

end
