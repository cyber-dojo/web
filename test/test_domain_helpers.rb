
module TestDomainHelpers # mix-in

  def groups(params = {})
    Groups.new(self, params)
  end

  def katas(params = {})
    Katas.new(self, params)
  end

  # - - - - - - - - - - - - - - - -

  def in_group(&block)
    group = groups.new_group(starter_manifest)
    block.call(group)
  end

  # - - - - - - - - - - - - - - - -

  def in_kata(&block)
    kata = katas.new_kata(starter_manifest)
    block.call(kata)
  end

  # - - - - - - - - - - - - - - - -

  def starter_manifest(display_name = default_display_name)
    exercise_name = default_exercise_name
    manifest = languages.manifest(display_name)
    em = exercises.manifest(exercise_name)
    manifest['visible_files'].merge!(em['visible_files'])
    manifest['exercise'] = em['display_name']    
    manifest['created'] = time.now
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

  def duration
    1.6543
  end

end
