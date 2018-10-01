require_relative '../../lib/phonetic_alphabet'
require_relative '../lib/hidden_file_remover'

class Kata

  def initialize(externals, id)
    # Does *not* validate.
    @externals = externals
    @id = id
  end

  # - - - - - - - - - - - - -

  def run_tests(image_name, max_seconds, delta, files)
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
    # it will interfere with the output pseudo-file.
    new_files.delete('output')
    changed_files['output'] = stdout + stderr

    # don't show generated files that match hidden filenames
    remove_hidden_files(new_files, hidden_filenames)

    # Singler's snapshot exactly mirrors the files after the test-event
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

  #TODO: rename to ran_tests()
  def tested(files, at, stdout, stderr, colour)
    args += [id, files, at, stdout, stderr, colour]
    increments = singler.ran_tests(*args)
    increments.map { |h| Tag.new(@externals, self, h) }
  end

  # - - - - - - - - - - - - -

  def exists?
    singler.id?(id)
  end

  def age
    last = lights[-1]
    last == nil ? 0 : (last.time - created).to_i
  end

  # - - - - - - - - - - - - -
  # identifier

  def id
    @id
  end

  def short_id
    id[0..5]
  end

  def phonetic_short_id
    Phonetic.spelling(short_id).join('-')
  end

  # - - - - - - - - - - - - -

  def group
    gid = manifest_property
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
    singler.increments(id).map { |h| Tag.new(@externals, self, h) }
  end

  def lights
    tags.select(&:light?)
  end

  def active?
    lights != []
  end

  # - - - - - - - - - - - - -
  # info-bar

  def display_name  # required
    # eg 'Python, py.test'
    manifest_property
  end

  def exercise
    manifest_property # present in language+testFramework kata
  end                 # not present in custom kata

  # - - - - - - - - - - - - -
  # filenames/tabs

  def filename_extension # required
    if manifest_property.is_a?(Array)
      manifest_property # eg  [ ".c", ".h" ]
    else
      [ manifest_property ] # eg ".py" -> [ ".py" ]
    end
  end

  def highlight_filenames # optional
    manifest_property || []
  end

  def hidden_filenames # optional
    manifest_property || []
  end

  def tab_size # optional
    manifest_property || 4
  end

  # - - - - - - - - - - - - -
  # runner

  def image_name # required
    manifest_property
  end

  def max_seconds # optional
    manifest_property || 10
  end

  def runner_choice # required
    manifest_property
  end

  # - - - - - - - - - - - - -
  # dashboard

  def created # required
    Time.mktime(*manifest_property)
  end

  def progress_regexs # optional
    # [] is not a valid progress_regex.
    # It needs two regexs.
    # This affects zipper.zip_tag()
    manifest_property || []
  end

  private # = = = = = = = = = =

  include HiddenFileRemover

  def timed_out_message(max_seconds)
    [
      "Unable to complete the tests in #{max_seconds} seconds.",
      'Is there an accidental infinite loop?',
      'Is the server very busy?',
      'Please try again.'
    ].join("\n") + "\n"
  end

  # - - - - - - - - - - - - -

  def manifest_property
    manifest[name_of(caller)]
  end

  # - - - - - - - - - - - - -

  def manifest
    @manifest ||= singler.manifest(id)
  end

  # - - - - - - - - - - - - -

  def name_of(caller)
    # eg caller[0] == "kata.rb:1077:in `tab_size'"
    /`(?<name>[^']*)/ =~ caller[0] && name
  end

  # - - - - - - - - - - - - -

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

# Each avatar does _not_ choose their own language+test.
# The language+test is chosen for the _kata_.
# cyber-dojo is a team-based Interactive Dojo Environment,
# not an Individual Development Environment
