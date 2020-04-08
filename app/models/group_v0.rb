# frozen_string_literal: true

require_relative 'id_generator'
require_relative 'id_pather'
require_relative 'kata_v0'
require_relative 'liner'
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
    saver.assert(manifest_create_command(id, json_plain(manifest)))
    id
  end

  # - - - - - - - - - - - - - - - - - - -

  def manifest(id)
    manifest_src = saver.assert(manifest_read_command(id))
    manifest = json_parse(manifest_src)
    manifest['visible_files'] = unlined_files(manifest['visible_files'])
    manifest
  end

  # - - - - - - - - - - - - - - - - - - -

  def join(id, indexes)
    manifest = self.manifest(id)
    manifest.delete('id')
    manifest['group_id'] = id
    commands = indexes.map{ |index| dir_make_command(id, index) }
    results = saver.run_until_true(commands)
    result_index = results.find_index(true)
    if result_index.nil?
      nil # full
    else
      index = indexes[result_index]
      manifest['group_index'] = index
      kata_id = @kata.create(manifest)
      saver.assert(saver.file_create_command(kata_id_filename(id, index), kata_id))
      kata_id
    end
  end

  # - - - - - - - - - - - - - - - - - - -

  def joined(id)
    katas_ids(katas_indexes(id))
  end

  # - - - - - - - - - - - - - - - - - - -

  def events(id)
    results = {}
    kindexes = katas_indexes(id)
    read_events_files_commands = katas_ids(kindexes).map do |kata_id|
      @kata.send(:events_file_read_command, kata_id)
    end
    katas_events = saver.assert_all(read_events_files_commands)
    kindexes.each.with_index(0) do |(kata_id,kata_index),index|
      results[kata_id] = {
        'index' => kata_index,
        'events' => events_parse(katas_events[index])
      }
    end
    results
  end

  private

  include Liner
  include OjAdapter

  # - - - - - - - - - - - - - - - - - - -

  def katas_ids(katas_indexes)
    katas_indexes.map{ |kata_id,_| kata_id }
  end

  # - - - - - - - - - - - - - - - - - - -

  def katas_indexes(id)
    read_commands = (0..63).map do |index|
      saver.file_read_command(kata_id_filename(id, index))
    end
    reads = saver.run_all(read_commands)
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

  def dir_make_command(id, *parts)
    saver.dir_make_command(group_id_path(id, *parts))
  end

  # - - - - - - - - - - - - - - - - - - - - - -

  def manifest_create_command(id, manifest_src)
    saver.file_create_command(manifest_filename(id), manifest_src)
  end

  def manifest_read_command(id)
    saver.file_read_command(manifest_filename(id))
  end

  # - - - - - - - - - - - - - -
  # names of files

  def manifest_filename(id)
    group_id_path(id, 'manifest.json')
    # eg id == 'chy6BJ' ==> '/cyber-dojo/groups/ch/y6/BJ/manifest.json'
    # eg content ==> {"display_name":"Ruby, MiniTest",...}
  end

  def kata_id_filename(id, index)
    group_id_path(id, index, 'kata.id')
    # eg id == 'chy6BJ', index == 11 ==> '/cyber-dojo/groups/ch/y6/BJ/11/kata.id'
    # eg content ==> 'k5ZTk0'
  end

  include IdPather

  # - - - - - - - - - - - - - -

  def events_parse(s)
    json_parse('[' + s.lines.join(',') + ']')
    # Alternative implementation, which tests show is slower.
    # s.lines.map { |line| json_parse(line) }
  end

  # - - - - - - - - - - - - - -

  def saver
    @externals.saver
  end

end
