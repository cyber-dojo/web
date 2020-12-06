
module TestDomainHelpers # mix-in

  def v_test?(n)
    hex_test_name.start_with?("<version=#{n}>")
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
    v1_id = '5U2J18' # "Bash, bats" v1
    manifest = model.kata_manifest(v1_id)
    %w( id created group_id group_index ).each {|key| manifest.delete(key) }
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
