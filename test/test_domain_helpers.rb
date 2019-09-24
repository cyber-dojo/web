
module TestDomainHelpers # mix-in

  def assert_schema_version(o)
    if v_test?(0)
      assert_equal 0, o.schema.version
    end
    if v_test?(1)
      assert_equal 1, o.schema.version
    end
  end

  # - - - - - - - - - - - - - - - - - - -

  def schema_version
    if v_test?(0)
      return 0
    end
    if v_test?(1)
      return 1
    end
  end

  # - - - - - - - - - - - - - - - - - - -

  def v_test?(n)
    hex_test_name.start_with?("<version=#{n}>")
  end

  # - - - - - - - - - - - - - - - - - - -

  def params
    @params ||= {}
    if v_test?(0)
      @params[:version] = 0
    end
    if v_test?(1)
      @params[:version] = 1
    end
    @params
  end

  # - - - - - - - - - - - - - - - - - - -

  def groups
    Groups.new(self, params)
  end

  def katas
    Katas.new(self, params)
  end

  # - - - - - - - - - - - - - - - -

  def in_group(&block)
    manifest = starter_manifest
    if v_test?(0)
      manifest['version'] = 0
    end
    if v_test?(1)
      manifest['version'] = 1
    end
    group = groups.new_group(manifest)
    block.call(group)
  end

  # - - - - - - - - - - - - - - - -

  def in_kata(&block)
    manifest = starter_manifest
    if v_test?(0)
      manifest['version'] = 0
    end
    if v_test?(1)
      manifest['version'] = 1
    end
    kata = katas.new_kata(manifest)
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

  def content(s)
    {
      'content' => s,
      'truncated' => false
    }
  end

  # - - - - - - - - - - - - - - - - - - - - - - -

  def duration
    1.6543
  end

end
