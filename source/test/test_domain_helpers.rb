module TestDomainHelpers

  def in_new_kata(&block)
    id = saver.kata_create(starter_manifest)
    kata = Kata.new(self, id)
    block.call(kata)
  end

  # - - - - - - - - - - - - - - - -

  def starter_manifest
    v1_id = '5U2J18' # "Bash, bats" - used as a manifest template
    manifest = saver.kata_manifest(v1_id)
    %w( id created group_id group_index ).each {|key| manifest.delete(key) }
    manifest['created'] = time.now
    manifest['version'] = 2
    manifest['visible_files'] = manifest['visible_files'].transform_values do |file|
      file.is_a?(Hash) ? file : { 'content' => file, 'truncated' => false }
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

  def laptop_id
    'a1' * 32 # a well-formed (64-char lowercase hex) laptop_id for tests to pass
  end

  # A fresh monotonic tab_seq for each event-write, mirroring the browser's
  # per-tab counter. Distinct per call so saver's (laptop_id, tab_seq, colour)
  # dedup never collapses two deliberate writes a test makes on one laptop_id.
  def next_tab_seq
    @next_tab_seq ||= 0
    @next_tab_seq += 1
  end

  def ran_summary(colour)
    {
      'duration' => duration,
      'colour' => colour,
      'predicted' => 'none'
    }
  end

end
