
module TestDomainHelpers # mix-in

  def in_group(&block)
    manifest = make_manifest({ 'display_name' => default_display_name })
    group = groups.new_group(manifest)
    block.call(group)
  end

  # - - - - - - - - - - - - - - - -

  def in_kata(&block)
    kata = make_language_kata({ 'display_name' => default_display_name })
    block.call(kata)
  end

  # - - - - - - - - - - - - - - - -

  def make_language_kata(options = {})
    katas.new_kata(make_manifest(options))
  end

  def make_manifest(options = {})
    display_name = options['display_name'] || default_display_name
    exercise_name = options['exercise'] || default_exercise_name
    manifest = languages.manifest(display_name)
    em = exercises.manifest(exercise_name)
    manifest['visible_files'].merge!(em['visible_files'])
    manifest['created'] = (options['created'] || time_now)
    manifest
  end

  def default_display_name
    'Ruby, MiniTest'
  end

  def default_exercise_name
    'Fizz Buzz'
  end

  def plain(files)
    files.map do |filename,file|
      [filename, file['content']]
    end.to_h
  end

  # - - - - - - - - - - - - - - - - - - - - - - -

  def groups
    Groups.new(self, version)
  end

  def katas
    Katas.new(self, version)
  end

  def version
    0
  end

  # - - - - - - - - - - - - - - - - - - - - - - -

  def time_now(now = Time.now)
    [now.year, now.month, now.day, now.hour, now.min, now.sec, now.usec]
  end

  def duration
    1.6543
  end

end
