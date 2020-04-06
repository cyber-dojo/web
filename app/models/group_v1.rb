# frozen_string_literal: true

require_relative 'id_generator'
require_relative 'id_pather'
require_relative 'kata_v1'
require_relative '../../lib/oj_adapter'

# 1. Manifest now has explicit version (1)
# 2. joined() now does 1 read, not 64 reads.
# 3. No longer stores JSON in pretty format.
# 4. No longer stores file contents in lined format.
# 5. Uses Oj as its JSON gem.

class Group_v1

  def initialize(externals)
    @kata = Kata_v1.new(externals)
    @externals = externals
  end

  # - - - - - - - - - - - - - - - - - - -

  def create(manifest)
    id = manifest['id'] = IdGenerator.new(@externals).group_id
    manifest['version'] = 1
    saver.batch_assert([
      manifest_write_command(id, json_plain(manifest)),
      katas_write_command(id, '')
    ])
    id
  end

  # - - - - - - - - - - - - - - - - - - -

  def manifest(id)
    manifest_src = saver.assert(manifest_read_command(id))
    json_parse(manifest_src)
  end

  # - - - - - - - - - - - - - - - - - - -

  def join(id, indexes)
    manifest = self.manifest(id)
    manifest.delete('id')
    manifest['group_id'] = id
    commands = indexes.map{ |index| create_command(id, index) }
    results = saver.batch_until_true(commands)
    result_index = results.find_index(true)
    if result_index.nil?
      nil # full
    else
      index = indexes[result_index]
      manifest['group_index'] = index
      kata_id = @kata.create(manifest)
      saver.assert(katas_append_command(id, "#{kata_id} #{index}\n"))
      kata_id
    end
  end

  # - - - - - - - - - - - - - - - - - - -

  def joined(id)
    katas_ids(katas_indexes(id))
  end

  # - - - - - - - - - - - - - - - - - - -

  def events(id)
    result = {}
    kindexes = katas_indexes(id)
    read_events_files_commands = katas_ids(kindexes).map do |kata_id|
      @kata.send(:events_read_command, kata_id)
    end
    katas_events = saver.batch_assert(read_events_files_commands)
    kindexes.each.with_index(0) do |(kata_id,kata_index),index|
      result[kata_id] = {
        'index' => kata_index,
        'events' => json_parse('[' + katas_events[index] + ']')
      }
    end
    result
  end

  private

  include OjAdapter

  # - - - - - - - - - - - - - - - - - - - - - -

  def katas_ids(katas_indexes)
    katas_indexes.map{ |kata_id,_| kata_id }
  end

  # - - - - - - - - - - - - - - - - - - -

  def katas_indexes(id)
    katas_src = saver.assert(katas_read_command(id))
    # G2ws77 15
    # w34rd5 2
    # ...
    katas_src
      .split
      .each_slice(2)
      .map{|kid,kindex| [kid,kindex.to_i] }
      .sort{|lhs,rhs| lhs[1] <=> rhs[1] }
    # [
    #   ['w34rd5', 2], #  2 == bat
    #   ['G2ws77',15], # 15 == fox
    #   ...
    # ]
  end

  # - - - - - - - - - - - - - - - - - - - - - -

  def create_command(id, *parts)
    saver.create_command(dirname(id, *parts))
  end

  # - - - - - - - - - - - - - - - - - - - - - -

  def manifest_write_command(id, manifest_src)
    saver.write_command(manifest_filename(id), manifest_src)
  end

  def manifest_read_command(id)
    saver.read_command(manifest_filename(id))
  end

  # - - - - - - - - - - - - - - - - - - - - - -

  def katas_write_command(id, src)
    saver.write_command(katas_filename(id), src)
  end

  def katas_append_command(id, src)
    saver.append_command(katas_filename(id), src)
  end

  def katas_read_command(id)
    saver.read_command(katas_filename(id))
  end

  # - - - - - - - - - - - - - -
  # names of dirs/files

  def dirname(id, *parts)
    group_id_path(id, *parts)
    # eg id == 'wAtCfj' ==> '/cyber-dojo/groups/wA/tC/fj'
  end

  def manifest_filename(id)
    group_id_path(id, 'manifest.json')
    # eg id == 'wAtCfj' ==> '/cyber-dojo/groups/wA/tC/fj/manifest.json'
    # eg content ==> {"display_name":"Ruby, MiniTest",...}
  end

  def katas_filename(id)
    group_id_path(id, 'katas.txt')
    # eg id == 'wAtCfj' ==> '/cyber-dojo/groups/wA/tC/fj/katas.txt'
    # eg content ==>
    # SyG9sT 50
    # zhTLfa 32
  end

  include IdPather

  # - - - - - - - - - - - - - -

  def saver
    @externals.saver
  end

end
