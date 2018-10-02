require_relative '../lib/hidden_file_remover'

class Kata

  def initialize(externals, id)
    @externals = externals
    @id = id
  end

  def id
    @id
  end

  def exists?
    singler.id?(id)
  end

  # - - - - - - - - - - - - - - - - - - - - - - - -

  def group
    # if the kata is in a group practice-session, the group, otherwise nil
    gid = manifest.group
    if gid
      @group ||= groups[gid]
    else
      nil
    end
  end

  def avatar
    # if the kata is in a group practice-session, the kata, otherwise nil
    if group
      @avatar ||= group.avatars
                       .detect{ |avatar| avatar.kata.id == id }
    else
      nil
    end
  end

  # - - - - - - - - - - - - - - - - - - - - - - - -

  def run_tests(image_name, max_seconds, delta, files, hidden_filenames)
    # run tests but don't store results
    stdout,stderr,status,
      colour,
        new_files,deleted_files,changed_files =
          runner.run_cyber_dojo_sh(image_name, id, max_seconds, delta, files)

    if colour == 'timed_out'
      stdout = timed_out_message(max_seconds) + stdout
    end

    # If there is a file called output remove it otherwise
    # it interferes with the output pseudo-file.
    new_files.delete('output')
    changed_files['output'] = stdout + stderr

    # Don't show generated files that match hidden filenames
    remove_hidden_files(new_files, hidden_filenames)

    # Stored snapshot exactly mirrors the files after the test-event
    # has completed. That is, after a test-event completes if you
    # refresh the page in the browser then nothing will change.
    deleted_files.keys.each { |filename| files.delete(filename) }
    new_files.each          { |filename,content| files[filename] = content }
    changed_files.each      { |filename,content| files[filename] = content }

    [stdout,stderr,status,
     colour,
     new_files,deleted_files,changed_files
    ]
  end

  def ran_tests(files, at, stdout, stderr, colour)
    # store results from run_tests()
    incs = singler.ran_tests(id, files, at, stdout, stderr, colour)
    tags = incs.map { |h| Tag.new(@externals, self, h) }
    tags.select(&:light?)
  end

  # - - - - - - - - - - - - - - - - - - - - - - - -

  def age
    last = lights[-1]
    last == nil ? 0 : (last.time - manifest.created).to_i
  end

  def visible_files
    # the most recent set of files passes to ran_tests()
    @visible_files ||= singler.visible_files(id)
  end

  def tags
    # an array of Tag objects, each one associated with
    # a kata event. Currently all tag objects represent
    # test-event, except the first one which represents
    # the kata's creation.
    increments.map { |h| Tag.new(@externals, self, h) }
  end

  def lights
    tags.select(&:light?)
  end

  def active?
    lights != []
  end

  def manifest
    @manifest ||= Manifest.new(@externals, id)
  end

  private

  include HiddenFileRemover

  def increments
    @increments ||= singler.increments(id)
  end

  def timed_out_message(max_seconds)
    [ "Unable to complete the tests in #{max_seconds} seconds.",
      'Is there an accidental infinite loop?',
      'Is the server very busy?',
      'Please try again.'
    ].join("\n") + "\n"
  end

  def groups
    Groups.new(@externals)
  end

  def singler
    @externals.singler
  end

  def runner
    @externals.runner
  end

end
