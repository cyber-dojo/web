require_relative '../../lib/string_cleaner'
require_relative '../../lib/time_now'
require_relative '../lib/hidden_file_remover'

class KataController < ApplicationController

  def group
    @kata = kata
  end

  def edit
    if avatar_name != ''
      # group session
      @kata = katas[sid(avatar_name)]
      @avatar_name = avatar_name
    else
      # individual session
      @kata = katas[id]
      @avatar_name = ''
    end
    @title = 'test:' + @kata.short_id
  end

  def sid(avatar_name)
    joined = grouper.joined(id)
    index = Avatars.names.index(avatar_name)
    joined[index.to_s]
  end

  def run_tests
    case runner_choice
    when 'stateless'
      runner.set_hostname_port_stateless
    when 'stateful'
      runner.set_hostname_port_stateful
    end

    incoming = params[:file_hashes_incoming]
    outgoing = params[:file_hashes_outgoing]
    delta = FileDeltaMaker.make_delta(incoming, outgoing)
    files = received_files

    args = []
    args << image_name  # eg 'cyberdojofoundation/gcc_assert'
    args << id
    args << max_seconds # eg 10
    args << delta
    args << files

    stdout,stderr,status,@colour,
      @new_files,@deleted_files,@changed_files = runner.run_cyber_dojo_sh(*args)

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

    args = [id, files, time_now, stdout, stderr, @colour]
    increments = singler.ran_tests(*args)
    tags = increments.map { |h| Tag.new(self, id, h) }
    lights = tags.select(&:light?)
    @was_tag = lights.size == 1 ? 0 : lights[-2].number
    @now_tag = lights[-1].number
    @id = id

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
