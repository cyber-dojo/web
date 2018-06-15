require_relative '../../lib/string_cleaner'
require_relative '../../lib/time_now'
require_relative '../lib/hidden_file_remover'

class KataController < ApplicationController

  def group
    @kata = kata
  end

  def edit
    @kata = kata
    @avatar = avatar
    @visible_files = @avatar.visible_files
    @traffic_lights = @avatar.lights
    @title = 'test:' + @kata.short_id + ':' + @avatar.name
  end

  def run_tests
    case runner_choice
    when 'stateless'
      runner.set_hostname_port_stateless
    when 'stateful'
      runner.set_hostname_port_stateful
    #when 'processful'
      #runner.set_hostname_port_processful
    end

    incoming = params[:file_hashes_incoming]
    outgoing = params[:file_hashes_outgoing]
    delta = FileDeltaMaker.make_delta(incoming, outgoing)
    files = received_files

    @avatar = Avatar.new(self, kata, avatar_name)
    args = []
    args << delta
    args << files
    args << max_seconds # eg 10
    args << image_name  # eg 'cyberdojofoundation/gcc_assert'

    stdout,stderr,status,@colour,
      @new_files,@deleted_files,@changed_files = avatar.test(*args)

    if @colour == 'timed_out'
      stdout = timed_out_message(max_seconds) + stdout
    end

    # If there is a file called output remove it otherwise
    # it will interfere with the @output pseudo-file.
    @new_files.delete('output')
    @changed_files['output'] = stdout + stderr

    # don't show generated hidden filenames
    remove_hidden_files(@new_files, hidden_filenames)

    # Storer's snapshot exactly mirrors the files after the test-event
    # has completed. That is, after a test-event completes if you
    # refresh the page in the browser then nothing will change.
    @deleted_files.keys.each do |filename|
      files.delete(filename)
    end

    @new_files.each do |filename,content|
      files[filename] = content
    end

    @changed_files.each do |filename,content|
      files[filename] = content
    end

    tags = avatar.tested(files, time_now, stdout, stderr, @colour)
    lights = tags.select(&:light?)
    @was_tag = lights.size == 1 ? 0 : lights[-2].number
    @now_tag = lights[-1].number

    respond_to do |format|
      format.js   { render layout: false }
      format.json { show_json }
    end
  end

  # - - - - - - - - - - - - - - - - - -

  def show_json
    # https://atom.io/packages/cyber-dojo
    render :json => {
      'visible_files' => avatar.visible_files,
             'avatar' => avatar.name,
         'csrf_token' => form_authenticity_token,
             'lights' => avatar.lights.map { |light| light.to_json }
    }
  end

  private # = = = = = = = = = = = = = =

  include HiddenFileRemover
  include StringCleaner
  include TimeNow

  def received_files
    seen = {}
    (params[:file_content] || {}).each do |filename, content|
      # Important to ignore output as it's not a 'real' file
      unless filename == 'output'
        content = cleaned(content)
        # Cater for windows line endings from windows browser
        seen[filename] = content.gsub(/\r\n/, "\n")
      end
    end
    seen
  end

  # - - - - - - - - - - - - - - - - - -

  def timed_out_message(max_seconds)
    [
      "Unable to complete the tests in #{max_seconds} seconds.",
      'Is there an accidental infinite loop?',
      'Is the server very busy?',
      'Please try again.'
    ].join("\n") + "\n"
  end

end
