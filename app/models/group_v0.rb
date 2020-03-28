# frozen_string_literal: true

require_relative 'id_generator'
require_relative 'id_pather'
require_relative 'kata_v0'
require_relative 'liner'
require_relative 'saver_asserter'
require_relative '../../lib/oj_adapter'

class Group_v0

  def initialize(externals)
    @kata = Kata_v0.new(externals)
    @externals = externals
  end

  # - - - - - - - - - - - - - - - - - - -

  def create(manifest)
    id = manifest['id'] = IdGenerator.new(@externals).group_id
    manifest['visible_files'] = lined_files(manifest['visible_files'])
    saver_assert(manifest_write_cmd(id, json_plain(manifest)))
    id
  end

  # - - - - - - - - - - - - - - - - - - -

  def manifest(id)
    manifest_src = saver_assert(manifest_read_cmd(id))
    manifest = json_parse(manifest_src)
    manifest['visible_files'] = unlined_files(manifest['visible_files'])
    manifest
  end

  # - - - - - - - - - - - - - - - - - - -

  def join(id, indexes)
    manifest = self.manifest(id)
    manifest.delete('id')
    manifest['group_id'] = id
    indexes.find do |index|
      if saver.public_send(*create_cmd(id, index))
        manifest['group_index'] = index
        kata_id = @kata.create(manifest)
        saver_assert(['write',id_path(id, index, 'kata.id'), kata_id])
        break kata_id
      end
    end # nil -> full
  end

  # - - - - - - - - - - - - - - - - - - -

  def joined(id)
    katas_indexes(id).map{ |kid,_| kid }
  end

  # - - - - - - - - - - - - - - - - - - -

  def events(id)
    results = {}
    kindexes = katas_indexes(id)
    read_events_files_commands = kindexes.map do |kid,_|
      @kata.send(:events_read_cmd, kid)
    end
    katas_events = saver.batch(read_events_files_commands)
    kindexes.each.with_index(0) do |(kid,kindex),index|
      results[kid] = {
        'index' => kindex,
        'events' => events_parse(katas_events[index])
      }
    end
    results
  end

  private

  include IdPather
  include Liner
  include OjAdapter
  include SaverAsserter

  # - - - - - - - - - - - - - - - - - - -

  def katas_indexes(id)
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
    # [
    #   ['w34rd5', 2], #  2 == bat
    #   ['G2ws77',15], # 15 == fox
    #   ...
    # ]
  end

  # - - - - - - - - - - - - - - - - - - - - - -

  def create_cmd(id, *parts)
    ['create', id_path(id, *parts)]
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

  # - - - - - - - - - - - - - -

  def events_parse(s)
    json_parse('[' + s.lines.join(',') + ']')
    # Alternative implementation, which tests show is slower.
    # s.lines.map { |line| json_parse(line) }
  end

  # - - - - - - - - - - - - - -

  def id_path(id, *parts)
    group_id_path(id, *parts)
  end

  # - - - - - - - - - - - - - -

  def saver
    @externals.saver
  end

end
