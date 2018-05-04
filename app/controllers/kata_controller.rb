require_relative '../../lib/phonetic_alphabet'
require_relative '../../lib/string_cleaner'
require_relative '../../lib/time_now'

class KataController < ApplicationController

  def individual
    @kata_id = kata.id
    @avatar_name = avatar.name
    @phonetic = Phonetic.spelling(kata.id[0..5])
  end

  def group
    @kata_id = kata.id
    @phonetic = Phonetic.spelling(kata.id[0..5])
  end

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

    case runner_choice
    when 'stateless'
      runner.set_hostname_port_stateless
    when 'stateful'
      runner.set_hostname_port_stateful
    #when 'processful'
      #runner.set_hostname_port_processful
    end
    args = []
    args << image_name  # eg 'cyberdojofoundation/gcc_assert'
    args << id          # eg 'FE8A79A264'
    args << avatar_name # eg 'salmon'
    args << max_seconds # eg 10
    args << delta
    args << files
    stdout,stderr,status,@colour = runner.run_cyber_dojo_sh(*args)

    if @colour == 'timed_out'
      stdout = timed_out_message(max_seconds) + stdout
    end

    # storer.avatar_ran_tests
    # - - - - - - - - - - - -
    # This validates a kata with the given id exists.
    # It could become a fire-and-forget method.
    # This might decrease run_tests() response time.
    # However, it is currently how the id is validated.
    # Also, I have tried to make it fire-and-forget using the
    # spawnling gem and it breaks a test in a non-obvious way.
    storer.avatar_ran_tests(id, avatar_name, files, time_now, stdout, stderr, @colour)

    @output = stdout + stderr

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

  def timed_out_message(max_seconds)
    [
      "Unable to complete the tests in #{max_seconds} seconds.",
      'Is there an accidental infinite loop?',
      'Is the server very busy?',
      'Please try again.'
    ].join("\n") + "\n"
  end

end
