
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

    @avatar = Avatar.new(self, kata, avatar_name)
    begin
      case runner_choice
      when 'stateless'
        runner.set_hostname_port_stateless
      when 'stateful'
        runner.set_hostname_port_stateful
      when 'processful'
        runner.set_hostname_port_processful
      end
      args = []
      args << image_name  # eg 'cyberdojofoundation/gcc_assert'
      args << id          # eg 'FE8A79A264'
      args << avatar_name # eg 'salmon'
      args << max_seconds # eg 10
      args << delta
      args << files
      stdout,stderr,status,@colour = runner.run_cyber_dojo_sh(*args)

    rescue StandardError => error
      # o) old kata could be being resumed
      # o) runner_choice could have switched
      case error.message
        when 'RunnerService:run_cyber_dojo_sh:kata_id:!exists'
          resurrect_kata
          resurrect_avatar(files)
          stdout,stderr,status,@colour = resurrect_run_tests(files, max_seconds)
        when 'RunnerService:run_cyber_dojo_sh:avatar_name:!exists'
          resurrect_avatar(files)
          stdout,stderr,status,@colour = resurrect_run_tests(files, max_seconds)
        else
          raise error
      end
    end

    if @colour == 'timed_out'
      @output = timed_out_message(max_seconds)
    else
      @output = stdout + stderr
    end

    # storer.avatar_ran_tests() validates a kata with the
    # given id exists. It is currently a synchronous call.
    storer.avatar_ran_tests(id, avatar_name, files, time_now, @output, @colour)

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

  def resurrect_run_tests(files, max_seconds)
    delta = { unchanged:files.keys, changed:[], deleted:[], new:[] }
    @avatar.test(delta, files, max_seconds)
  end

  def timed_out_message(max_seconds)
    [
      "Unable to complete the tests in #{max_seconds} seconds.",
      'Is there an accidental infinite loop?',
      'Is the server very busy?',
      'Please try again.'
    ].join("\n")
  end

end
