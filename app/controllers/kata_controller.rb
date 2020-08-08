
class KataController < ApplicationController

  def group
    @id = id
  end

  def edit
    # who
    @id = kata.id
    @group_id = kata.group.id
    @avatar_name = kata.avatar_name
    @avatar_index = kata.avatar_index
    @version = kata.schema.version
    if @group_id.nil?
      @title = @id
    else
      @title = "#{@avatar_name}:#{@group_id}"
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
      kata.ran_tests(@id, @index, files, @stdout, @stderr, @status, {
        'time' => t1,
        'duration' => duration,
        'colour' => @outcome,
        'predicted' => predicted
      })
    rescue SaverService::Error => error
      @out_of_sync = true
      STDOUT.puts(error.message);
      STDOUT.flush
    end

    respond_to do |format|
      format.js   { render layout:false }
      format.json { show_json }
    end
  end

  # - - - - - - - - - - - - - - - - - -

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

  def to_json(light)
    {
      'colour' => light.colour,
      'time'   => light.time,
      'index'  => light.index
    }
  end

end

=begin
  def edit_offline
    manifest = starter_manifest
    @id = '999999'
    @title = "kata: #{@id}"
    # who
    @avatar_name = ''
    @avatar_index = nil
    @group_id = nil
    # no previous lights
    @lights = []
    # no previous files
    @files = manifest['visible_files']
    # required parameters
    @image_name = manifest['image_name']
    @filename_extension = manifest['filename_extension']
    # optional parameters
    @hidden_filenames = manifest['hidden_filenames'] || []
    @highlight_filenames = manifest['highlight_filenames'] || []
    @max_seconds = manifest['max_seconds'] || 10
    @tab_size = manifest['tab_size'] || 4
    # footer info
    @display_name = manifest['display_name']
    @exercise = manifest['exercise']
    # TODO: Turn off traffic-light click opens diff review
    # TODO: Turn off traffic-lights tool-tip
  end

  def starter_manifest
    exercise_name = params['exercise']
    em = exercises.manifest(exercise_name)
    language_name = params['language']
    manifest = languages.manifest(language_name)
    manifest['visible_files'].merge!(em['visible_files'])
    manifest['exercise'] = em['display_name']
    manifest['created'] = time.now
    manifest
  end
=end
