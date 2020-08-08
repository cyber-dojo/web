
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

  def groups(params = {})
    Groups.new(self, params)
  end

  def katas(params = {})
    Katas.new(self, params)
  end

  # - - - - - - - - - - - - - - - -

  def in_new_group(params = {}, &block)
    groups = Groups.new(self, params)
    group = groups.new_group(starter_manifest)
    block.call(group)
  end

  # - - - - - - - - - - - - - - - -

  def in_new_kata(params = {}, &block)
    katas = Katas.new(self, params)
    kata = katas.new_kata(starter_manifest)
    block.call(kata)
  end

  # - - - - - - - - - - - - - - - -

  def starter_manifest(display_name = DEFAULT_DISPLAY_NAME)
    manifest = languages_start_points.manifest(display_name)
    exercise_name = DEFAULT_EXERCISE_NAME
    em = exercises_start_points.manifest(exercise_name)
    manifest['visible_files'].merge!(em['visible_files'])
    manifest['exercise'] = em['display_name']
    manifest['created'] = time.now
    if v_test?(0)
      manifest['version'] = 0
    end
    if v_test?(1)
      manifest['version'] = 1
    end
    manifest
  end

  # - - - - - - - - - - - - - - - -

  DEFAULT_DISPLAY_NAME = 'Ruby, MiniTest'

  DEFAULT_EXERCISE_NAME = 'Fizz Buzz'

  # - - - - - - - - - - - - - - - -

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

  def ran_summary(now, colour)
    { 'time' => now,
      'duration' => duration,
      'colour' => colour,
      'predicted' => 'none'
    }
  end

end
