
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

  # - - - - - - - - - - - - - - - -

  def in_new_group(&block)
    id = model.group_create(starter_manifest)
    block.call(groups[id])
  end

  def groups(params = {})
    Groups.new(self, params)
  end

  # - - - - - - - - - - - - - - - -

  def in_new_kata(&block)
    id = model.kata_create(starter_manifest)
    block.call(katas[id])
  end

  def katas(params = {})
    Katas.new(self, params)
  end

  # - - - - - - - - - - - - - - - -

  def starter_manifest
    v1_id = '5U2J18' # "Bash, bats"
    manifest = model.kata_manifest(v1_id)
    %w( id created group_id group_index ).each {|key| manifest.delete(key) }
    manifest['exercise'] = DEFAULT_EXERCISE_NAME
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

  DEFAULT_LANGUAGE_NAME = 'Ruby, MiniTest'

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

  def ran_summary(colour)
    {
      'duration' => duration,
      'colour' => colour,
      'predicted' => 'none'
    }
  end

end
