
class KataController < ApplicationController

  def edit
    @kata = kata
    @avatar = avatar
    @tab = ' ' * @kata.tab_size
    @visible_files = @avatar.visible_files
    @traffic_lights = @avatar.lights
    @output = @visible_files['output']
    @title = 'test:' + @kata.id[0..5] + ':' + @avatar.name
  end

  def run_tests
    fail "sorry, we can't do that" if kata.nil? || avatar.nil?
    @avatar = avatar

    incoming = params[:file_hashes_incoming]
    outgoing = params[:file_hashes_outgoing]
    delta = FileDeltaMaker.make_delta(incoming, outgoing)
    files = received_files
    stdout,stderr,status = @avatar.test(delta, files)
    if status == 'no_avatar'
       # kata was created before new separated runner-microservice
       # so runner has to be informed of this avatar's existence...
       # Do this maintaining most up to date diff
       args = []
       args << kata.image_name
       args << kata.id
       args << avatar.name
       args << avatar.visible_files
       runner.new_avatar(*args)
       delta = FileDeltaMaker.make_delta(avatar.visible_files, files)
       stdout,stderr,status = @avatar.test(delta, files)
    end
    if status == 'timed_out'
      max_seconds = 10
      @output = "Unable to complete the tests in #{max_seconds} seconds.\n" +
          "Is there an accidental infinite loop?\n" +
          "Is the server very busy?\n" +
          "Please try again."
      @test_colour = 'timed_out'
    else
      @output = stdout + stderr
      @test_colour = kata.red_amber_green(@output)
    end
    @avatar.tested(files, time_now, @output, @test_colour)

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

  include MakefileFilter
  include StringCleaner
  include TimeNow

  def received_files
    seen = {}
    (params[:file_content] || {}).each do |filename, content|
      content = cleaned(content)
      # Cater for windows line endings from windows browser
      content = content.gsub(/\r\n/, "\n")
      seen[filename] = makefile_filter(filename, content)
    end
    seen
  end

end
