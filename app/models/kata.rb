require_relative '../lib/hidden_file_remover'

class Kata

  def initialize(externals, id)
    # Does *not* validate.
    @externals = externals
    @id = id
  end

  attr_reader :id

  def manifest
    Manifest.new(@externals, id)
  end

  def exists?
    singler.id?(id)
  end

  # - - - - - - - - - - - - -

  def run_tests(image_name, max_seconds, delta, files, hidden_filenames)
    args = []
    args << image_name    # eg 'cyberdojofoundation/gcc_assert'
    args << id            # eg 'FE8A79A264'
    args << max_seconds   # eg 10
    args << delta
    args << files

    stdout,stderr,status,colour,
      new_files,deleted_files,changed_files = runner.run_cyber_dojo_sh(*args)

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
    deleted_files.keys.each do |filename|
      files.delete(filename)
    end

    new_files.each do |filename,content|
      files[filename] = content
    end

    changed_files.each do |filename,content|
      files[filename] = content
    end

    [stdout,stderr,status,
     colour,
     new_files,deleted_files,changed_files
    ]
  end

  # - - - - - - - - - - - - -

  def ran_tests(files, at, stdout, stderr, colour)
    increments = singler.ran_tests(id, files, at, stdout, stderr, colour)
    tags = increments.map { |h| Tag.new(@externals, self, h) }
    tags.select(&:light?)
  end

  # - - - - - - - - - - - - -

  def age
    last = lights[-1]
    last == nil ? 0 : (last.time - manifest.created).to_i
  end

  # - - - - - - - - - - - - -

  def group
    gid = manifest.group
    if gid
      groups[gid]
    else
      nil
    end
  end

  def avatar
    if group
      group.avatars.detect{|avatar| avatar.kata.id == id }
    else
      nil
    end
  end

  # - - - - - - - - - - - - -

  def visible_files
    singler.visible_files(id)
  end

  def tags
    singler.increments(id).map { |h| Tag.new(externals, self, h) }
  end

  def lights
    tags.select(&:light?)
  end

  def active?
    lights != []
  end

  private # = = = = = = = = = =

  attr_reader :externals

  include HiddenFileRemover

  def timed_out_message(max_seconds)
    [
      "Unable to complete the tests in #{max_seconds} seconds.",
      'Is there an accidental infinite loop?',
      'Is the server very busy?',
      'Please try again.'
    ].join("\n") + "\n"
  end

  def groups
    Groups.new(externals)
  end

  def singler
    externals.singler
  end

  def runner
    externals.runner
  end

end
