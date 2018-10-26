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
    gid = manifest.group
    if gid
      Group.new(@externals, gid)
    else
      nil
    end
  end

  # - - - - - - - - - - - - - - - - - - - - - - - -

  def avatar_name
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
    %w( stdout stderr status ).each do |output|
      incoming.delete(output)
      outgoing.delete(output)
    end
    delta = FileDeltaMaker.make_delta(incoming, outgoing)

    image_name = params[:image_name]

    max_seconds = params[:max_seconds].to_i

    files = cleaned_files(params[:file_content])
    %w( stdout stderr status ).each do |output|
      files.delete(output)
    end

    stdout,stderr,status,
      colour,
        new_files,deleted_files,changed_files =
          runner.run_cyber_dojo_sh(image_name, id, max_seconds, delta, files)

    if colour == 'timed_out'
      stdout = timed_out_message(max_seconds) + stdout
    end

    # If the runner has created an output file remove it
    # otherwise it interferes with the pseudo output-files.
    %w( stdout stderr status ).each do |output|
      new_files.delete(output)
    end

    hidden_filenames = JSON.parse(params[:hidden_filenames])
    remove_hidden_files(new_files, hidden_filenames)

    # ensure (saved) files reflect changes
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
    saver.kata_ran_tests(id, n, files, at, stdout, stderr, status, colour)
  end

  # - - - - - - - - - - - - - - - - - - - - - - - -

  def age
    # in seconds
    (most_recent.time - manifest.created).to_i
  end

  def files
    most_recent.files
  end

  def stdout
    most_recent.stdout
  end

  def stderr
    most_recent.stderr
  end

  def status
    most_recent.status
  end

  def lights
    # currently all events are test-events, except
    # the first creation event.
    events.select(&:light?)
  end

  def active?
    lights != []
  end

  def events
    @events ||= saver.kata_events(id)
    @events.map.with_index { |h,i| Event.new(@externals, self, h, i) }
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

  def most_recent
    events.last
  end

  def saver
    @externals.saver
  end

  def runner
    @externals.runner
  end

end
