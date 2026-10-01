module TestDomainHelpers

  def in_new_kata(&block)
    id = saver.kata_create(starter_manifest)
    kata = Web::Kata.new(externals, id)
    block.call(kata)
  end

  # - - - - - - - - - - - - - - - -

  def starter_manifest
    v1_id = '5U2J18' # "Bash, bats" - used as a manifest template
    manifest = saver.kata_manifest(v1_id)
    %w( id created group_id group_index ).each {|key| manifest.delete(key) }
    manifest['created'] = externals.time.now
    manifest['version'] = 2
    manifest['rag_lambda'] = rag_lambda
    manifest
  end

  # - - - - - - - - - - - - - - - -

  # The red-amber-green lambda source a manifest carries, which the browser
  # posts with each run_tests so runner evals it instead of reading the lambda
  # from the language image. start-points-base inlines the source of a start
  # point's red_amber_green.rb into the manifest it serves; this is the
  # bash-bats source, matching the "Bash, bats" kata starter_manifest builds on.
  def rag_lambda
    <<~'RUBY'
      lambda { |stdout,stderr,status|
        output = stdout + stderr
        return :green if status === 0
        return :amber if /.*: line \d+:/.match(output) && status === 1
        return :red
      }
    RUBY
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

  # This tab's half of the writer id, mirroring the browser's per-tab 32-char
  # hex tabId. Appended to the laptop half so saver can tell a write made in
  # this tab from one made in another tab on the same laptop.
  def tab_id
    'b2' * 16 # a well-formed (32-char lowercase hex) tab_id for tests to pass
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
