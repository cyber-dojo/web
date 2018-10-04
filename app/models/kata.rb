require_relative '../lib/file_delta_maker'
require_relative '../lib/hidden_file_remover'
require_relative '../../lib/cleaner'

class Kata

  def initialize(externals, id, group_index = [nil,nil])
    @externals = externals
    @id = id
    @group,index = group_index
    @avatar = @group ? Avatar.new(self, index) : nil
  end

  def id
    @id
  end

  def exists?
    singler.id?(id)
  end

  # - - - - - - - - - - - - - - - - - - - - - - - -

  def group
    # if in a group practice-session, the group, otherwise nil
    @group
  end

  def avatar
    # if in a group practice-session, the avatar, otherwise nil
    @avatar
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

  def ran_tests(files, at, stdout, stderr, status, colour)
    # save run_tests() results.
    incs = singler.ran_tests(id, files, at, stdout, stderr, status, colour)
    tags = incs.map { |h| Tag.new(@externals, self, h) }
    tags.select(&:light?)
  end

  # - - - - - - - - - - - - - - - - - - - - - - - -

  def age
    last = lights[-1]
    last == nil ? 0 : (last.time - manifest.created).to_i
  end

  def visible_files
    # the most recent set of files passed to ran_tests()
    @visible_files ||= singler.visible_files(id)
  end

  def tags
    # each array element is represents a kata event.
    @tags ||= singler.tags(id)
    @tags.map { |h| Tag.new(@externals, self, h) }
  end

  def lights
    # currently all tag objects are test-events, except
    # the first one which represents the kata's creation.
    tags.select(&:light?)
  end

  def active?
    lights != []
  end

  def manifest
    @manifest ||= Manifest.new(singler.manifest(id))
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

  def singler
    @externals.singler
  end

  def runner
    @externals.runner
  end

end
