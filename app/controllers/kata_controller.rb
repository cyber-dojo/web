
class KataController < ApplicationController

  def group
    @id = id
  end

  def edit
    mapped_id {
      manifest = kata.manifest
      @version = kata.schema.version
      @id = kata.id
      @title = "kata: #{@id}"
      # who
      @avatar_name = kata.avatar_name
      @avatar_index = kata.avatar_index
      @group_id = kata.group.id
      # previous traffic-light-lights
      @lights = kata.lights
      @last_index = kata.events.last.index
      # most recent files
      @files = kata.files(:with_output)
      # required parameters
      @image_name = manifest.image_name
      @filename_extension = manifest.filename_extension
      # optional parameters
      @hidden_filenames = manifest.hidden_filenames
      @highlight_filenames = manifest.highlight_filenames
      @max_seconds = manifest.max_seconds
      @tab_size = manifest.tab_size
      # footer info
      @display_name = manifest.display_name
      @exercise = manifest.exercise
    }
  end

  # - - - - - - - - - - - - - - - - - -

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
    @last_index = 0
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
=end

  # - - - - - - - - - - - - - - - - - -

  def run_tests
    t1 = time.now

    result,files,@created,@deleted,@changed = kata.run_tests
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
      rescue RaggerService::Error
        colour = 'faulty'
        # TODO: @message on footer...
      end
    end

    t2 = time.now
    duration = Time.mktime(*t2) - Time.mktime(*t1)
    index = params[:index].to_i + 1
    args = []
    args << index                       # index of traffic-light event
    args << files                       # including @created,@deleted,@changed
    args += [t1,duration]               # how long runner+ragger took
    args += [@stdout, @stderr, @status] # output of [test] kata.run_tests()
    args << colour
    begin
      kata.ran_tests(*args)
    rescue SaverService::Error
      #TODO: @message on footer...
    end

    @light = Event.new(kata, { 'time' => t1, 'colour' => colour, 'index' => index})
    @id = kata.id

    respond_to do |format|
      format.js   { render layout:false }
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

  def to_json(light)
    {
      'colour' => light.colour,
      'time'   => light.time,
      'index'  => light.index
    }
  end

=begin
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

end
