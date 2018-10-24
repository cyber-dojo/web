require_relative '../lib/file_delta_maker'
require_relative '../lib/hidden_file_remover'
require_relative '../../lib/cleaner'

class Kata

  def initialize(externals, id)
    @externals = externals
    @id = id
  end

  # - - - - - - - - - - - - - - - - - - - - - - - -

  def id
    @id
  end

  # - - - - - - - - - - - - - - - - - - - - - - - -

  def exists?
    saver.kata_exists?(id)
  end

  # - - - - - - - - - - - - - - - - - - - - - - - -

  def group
    # if in a group practice-session
    # then the group, otherwise nil
    gid = manifest.group
    if gid.nil?
      nil
    else
      Group.new(@externals, gid)
    end
  end

  # - - - - - - - - - - - - - - - - - - - - - - - -

  def avatar_name
    # if in a group practice-session
    # then the avatar's name, otherwise ''
    if group
      Avatars.names[manifest.index]
    else
      ''
    end
  end

  # - - - - - - - - - - - - - - - - - - - - - - - -

  def run_tests(params)
    # run tests but don't save the results
    case params[:runner_choice]
    when 'stateless'
      runner.set_hostname_port_stateless
    when 'stateful'
      runner.set_hostname_port_stateful
    end

    incoming = params[:file_hashes_incoming]
    outgoing = params[:file_hashes_outgoing]

    image_name = params[:image_name]
    max_seconds = params[:max_seconds].to_i
    delta = FileDeltaMaker.make_delta(incoming, outgoing)
    files = cleaned_files(params[:file_content])
    files.delete('output')

    stdout,stderr,status,
      colour,
        new_files,deleted_files,changed_files =
          runner.run_cyber_dojo_sh(image_name, id, max_seconds, delta, files)

    if colour == 'timed_out'
      stdout = timed_out_message(max_seconds) + stdout
    end

    # If the runner has created a file called output remove it
    # otherwise it interferes with the output pseudo-file.
    new_files.delete('output')
    changed_files['output'] = stdout + stderr

    hidden_filenames = JSON.parse(params[:hidden_filenames])
    remove_hidden_files(new_files, hidden_filenames)

    new_files.each     { |filename,content| files[filename] = content }
    deleted_files.each { |filename,_      | files.delete(filename)    }
    changed_files.each { |filename,content| files[filename] = content }

    [stdout,stderr,status,
     colour,
     files,new_files,deleted_files,changed_files
    ]
  end

  # - - - - - - - - - - - - - - - - - - - - - - - -

  def ran_tests(n, files, at, stdout, stderr, status, colour)
    # save run_tests() results.
    incs = saver.kata_ran_tests(id, n, files, at, stdout, stderr, status, colour)
    tags = incs.map { |h| Tag.new(@externals, self, h) }
    tags.select(&:light?)
  end

  # - - - - - - - - - - - - - - - - - - - - - - - -

  def age
    last = lights[-1]
    last == nil ? 0 : (last.time - manifest.created).to_i
  end

  def files
    # the most recent set of files passed to ran_tests()
    @files ||= saver.kata_event(id, -1)['files']
  end

  def lights
    # currently all tag objects are test-events, except
    # the first one which represents the kata's creation.
    tags.select(&:light?)
  end

  def active?
    lights != []
  end

  def tags # TODO: rename to events
    @events ||= saver.kata_events(id)
    @events.map { |h| Tag.new(@externals, self, h) }
  end

  def manifest
    @manifest ||= Manifest.new(saver.kata_manifest(id))
  end

  private

  include FileDeltaMaker
  include HiddenFileRemover
  include Cleaner

  def timed_out_message(max_seconds)
    [ "Unable to complete the tests in #{max_seconds} seconds.",
      'Is there an accidental infinite loop?',
      'Is the server very busy?',
      'Please try again.'
    ].join("\n") + "\n"
  end

  def saver
    @externals.saver
  end

  def runner
    @externals.runner
  end

end
