# frozen_string_literal: true

require_relative 'liner'
require_relative '../../lib/oj_adapter'
require_relative 'kata_v1'
require_relative '../services/saver_exception'

class Group_v1

  def initialize(externals)
    @kata = Kata_v1.new(externals)
    @externals = externals
  end

  # - - - - - - - - - - - - - - - - - - -

  def exists?(id)
    saver.send(*exists_cmd(id))
  end

  # - - - - - - - - - - - - - - - - - - -

  def create(manifest)
    id = manifest['id'] = generate_id
    manifest['visible_files'] = lined_files(manifest['visible_files'])
    unless saver.send(*manifest_write_cmd(id, json_plain(manifest)))
      fail invalid('id', id)
    end
    id
  end

  # - - - - - - - - - - - - - - - - - - -

  def manifest(id)
    manifest_src = saver.send(*manifest_read_cmd(id))
    unless manifest_src.is_a?(String)
      fail invalid('id', id)
    end
    manifest = json_parse(manifest_src)
    manifest['visible_files'] = unlined_files(manifest['visible_files'])
    manifest
  end

  # - - - - - - - - - - - - - - - - - - -

  def join(id, indexes)
    unless exists?(id)
      fail invalid('id', id)
    end
    manifest = self.manifest(id)
    manifest.delete('id')
    manifest['group_id'] = id
    indexes.each do |index|
      if saver.send(*create_cmd(id, index))
        manifest['group_index'] = index
        kata_id = @kata.create(manifest)
        saver.write(id_path(id, index, 'kata.id'), kata_id)
        return kata_id
      end
    end
    nil
  end

  # - - - - - - - - - - - - - - - - - - -

  def joined(id)
    if !exists?(id)
      nil
    else
      kata_indexes(id).map{ |kid,_| kid }
    end
  end

  # - - - - - - - - - - - - - - - - - - -

  def events(id)
    if !exists?(id)
      events = nil
    else
      kindexes = kata_indexes(id)
      read_events_files_commands = kindexes.map do |kid,_|
        @kata.send(:events_read_cmd, kid)
      end
      katas_events = saver.batch(read_events_files_commands)
      events = {}
      kindexes.each.with_index(0) do |(kid,kindex),index|
        events[kid] = {
          'index' => kindex,
          'events' => events_parse(katas_events[index])
        }
      end
    end
    events
  end

  private

  include OjAdapter
  include Liner

  def generate_id
    loop do
      id = id_generator.id
      if saver.create(id_path(id))
        return id
      end
    end
  end

  # - - - - - - - - - - - - - - - - - - - - - -

  def create_cmd(id, *parts)
    ['create', id_path(id, *parts)]
  end

  def exists_cmd(id)
    ['exists?', id_path(id)]
  end

  # - - - - - - - - - - - - - - - - - - - - - -

  def manifest_write_cmd(id, manifest_src)
    ['write', manifest_filename(id), manifest_src]
  end

  def manifest_read_cmd(id)
    ['read', manifest_filename(id)]
  end

  def manifest_filename(id)
    id_path(id, 'manifest.json')
  end

  # - - - - - - - - - - - - - - - - - - -

  def kata_indexes(id)
    read_commands = (0..63).map do |index|
      ['read', id_path(id, index, 'kata.id')]
    end
    reads = saver.batch(read_commands)
    # reads is an array of 64 entries, eg
    # [
    #    nil,      # 0
    #    nil,      # 1
    #    'w34rd5', # 2
    #    nil,      # 3
    #    'G2ws77', # 4
    #    nil
    #    ...
    # ]
    # indicating there are joined animals at indexes
    # 2 (bat) id == w34rd5
    # 4 (bee) id == G2ws77
    reads.each.with_index(0).select{ |kid,_| kid }
    # Select the non-nil entries whilst retaining the index
    # [ ['w34rd5',2], ['G2ws77',4], ... ]
  end

  # - - - - - - - - - - - - - -

  def events_parse(s)
    json_parse('[' + s.lines.join(',') + ']')
    # Alternative implementation, which tests show is slower.
    # s.lines.map { |line| json_parse(line) }
  end

  # - - - - - - - - - - - - - -

  def id_path(id, *parts)
    # Using 2/2/2 split.
    # See https://github.com/cyber-dojo/id-split-timer
    args = ['', 'groups', id[0..1], id[2..3], id[4..5]]
    args += parts.map(&:to_s)
    File.join(*args)
  end

  # - - - - - - - - - - - - - -

  def invalid(name, value)
    SaverException.new(json_pretty({
      "message" => "#{name}:invalid:#{value}"
    }))
  end

  # - - - - - - - - - - - - - -

  def saver
    @externals.saver
  end

  def id_generator
    @externals.id_generator
  end

end
