
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
    @avatar = Avatar.new(kata, avatar_name)
    incoming = params[:file_hashes_incoming]
    outgoing = params[:file_hashes_outgoing]
    delta = FileDeltaMaker.make_delta(incoming, outgoing)
    files = received_files
    max_seconds = 10

    begin
      stdout,stderr,status,colour = @avatar.test(delta, files, max_seconds, image_name)
    rescue StandardError => error
      # Old kata could be being resumed
      # Runner implementation could have switched
      case error.message
        when 'RunnerService:run:kata_id:!exists'
          resurrect_kata
          resurrect_avatar
          stdout,stderr,status,colour = resurrect_run_tests(files, max_seconds)
        when 'RunnerService:run:avatar_name:!exists'
          resurrect_avatar
          stdout,stderr,status,colour = resurrect_run_tests(files, max_seconds)
        else
          raise error
      end
    end

    if status == 'timed_out'
      @output = [
        "Unable to complete the tests in #{max_seconds} seconds.",
        'Is there an accidental infinite loop?',
        'Is the server very busy?',
        'Please try again.'
      ].join("\n")
      @test_colour = 'timed_out'
    elsif colour.nil?
      @output = stdout + stderr
      @test_colour = ragger.colour(id, stdout, stderr)
    else
      @output = stdout + stderr
      @test_colour = colour
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

  def resurrect_kata
    runner.kata_new(kata.image_name, kata.id)
  end

  def resurrect_avatar
    args = [ kata.image_name, kata.id, @avatar.name ]
    args << @avatar.visible_files
    runner.avatar_new(*args)
  end

  def resurrect_run_tests(files, max_seconds)
    delta = FileDeltaMaker.make_delta(@avatar.visible_files, files)
    args = [ delta, files, max_seconds ]
    @avatar.test(*args)
  end

end
