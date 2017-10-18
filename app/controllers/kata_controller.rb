
class KataController < ApplicationController

  def edit
    @kata = kata
    @avatar = avatar
    @visible_files = @avatar.visible_files
    @traffic_lights = @avatar.lights
    @output = @visible_files['output']
    @title = 'test:' + @kata.id[0..5] + ':' + @avatar.name
  end

  def run_tests
    incoming = params[:file_hashes_incoming]
    outgoing = params[:file_hashes_outgoing]
    delta = FileDeltaMaker.make_delta(incoming, outgoing)
    files = received_files
    max_seconds = 10

    @avatar = Avatar.new(kata, avatar_name)
    begin
      args = []
      args << image_name        # eg 'cyberdojofoundation/gcc_assert'
      args << id                # eg 'FE8A79A264'
      args << avatar_name       # eg 'salmon'
      args << max_seconds       # eg 10
      args << delta
      args << files
      if runner_choice == 'stateless'
        stdout,stderr,status,colour = runner.run_stateless(*args)
      else
        stdout,stderr,status,colour = runner.run_stateful(*args)
      end
    rescue StandardError => error
      # Old kata could be being resumed
      # Runner implementation could have switched
      case error.message
        when 'RunnerService:run:kata_id:!exists'
          resurrect_kata
          resurrect_avatar(files)
          stdout,stderr,status,colour = resurrect_run_tests(max_seconds)
        when 'RunnerService:run:avatar_name:!exists'
          resurrect_avatar(files)
          stdout,stderr,status,colour = resurrect_run_tests(max_seconds)
        else
          raise error
      end
    end

    @test_colour = colour
    if colour == 'timed_out'
      @output = [
        "Unable to complete the tests in #{max_seconds} seconds.",
        'Is there an accidental infinite loop?',
        'Is the server very busy?',
        'Please try again.'
      ].join("\n")
    else
      @output = stdout + stderr
    end

    # storer.avatar_ran_tests) is the only thing that validates
    # a kata with the given id exists. It is currently a
    # synchronous call. If it becomes an asynchronous (fire and forget)
    # call then revisit kata-id validation.
    storer.avatar_ran_tests(id, avatar_name, files, time_now, @output, @test_colour)

    respond_to do |format|
      format.js   { render layout: false }
      format.json { show_json }
    end
  end

  def show_json
    # https://atom.io/packages/cyber-dojo
    render :json => {
      'visible_files' => avatar.visible_files,
             'avatar' => avatar.name,
         'csrf_token' => form_authenticity_token,
             'lights' => avatar.lights.map { |light| light.to_json }
    }
  end

  private

  include StringCleaner
  include TimeNow

  def received_files
    seen = {}
    (params[:file_content] || {}).each do |filename, content|
      content = cleaned(content)
      # Cater for windows line endings from windows browser
      seen[filename] = content.gsub(/\r\n/, "\n")
    end
    seen
  end

  def resurrect_kata
    runner.kata_new(kata.image_name, kata.id)
  end

  def resurrect_avatar(files)
    args = [ kata.image_name, kata.id, @avatar.name, files ]
    runner.avatar_new(*args)
  end

  def resurrect_run_tests(max_seconds)
    delta = { unchanged:[], changed:[], deleted:[], new:[] }
    @avatar.test(delta, files={}, max_seconds)
  end

end
