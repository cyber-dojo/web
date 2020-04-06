# frozen_string_literal: true

require_relative 'id_generator'
require_relative 'id_pather'
require_relative '../../lib/oj_adapter'

# 1. Manifest now has explicit version (1)
# 2. Manifest is retrieved in single read call.
# 3. No longer stores JSON in pretty format.
# 4. No longer stores file contents in lined format.
# 5. Uses Oj as its JSON gem.
# 6. Stores explicit index in events.json summary file.
#    This makes using index==-1 robust when traffic-lights
#    are lost due to Saver outages.
#    was    { ... } # 0
#           { ... } # 1      then 2-23 outage
#           { ... } # 24
#    now    { ..., "index" => 0 }
#           { ..., "index" => 1 }
#           { ..., "index" => 24 }
# 7. No longer uses separate dir for each event file.
#    This makes ran_tests() faster as it no longer needs
#    a create_command() in its saver.batch call.
#    was     /cyber-dojo/katas/e3/T6/K2/0/event.json
#    now     /cyber-dojo/katas/e3/T6/K2/0.event.json

class Kata_v1

  def initialize(externals)
    @externals = externals
  end

  # - - - - - - - - - - - - - - - - - - -

  def create(manifest)
    id = manifest['id'] = IdGenerator.new(@externals).kata_id
    manifest['version'] = 1
    event_summary = {
      'index' => 0,
      'time' => manifest['created'],
      'event' => 'created'
    }
    event0 = {
      'files' => manifest['visible_files']
    }
    saver.batch_assert([
      manifest_write_command(id, json_plain(manifest)),
      events_write_command(id, json_plain(event_summary)),
      event_write_command(id, 0, json_plain(event0.merge(event_summary)))
    ])
    id
  end

  # - - - - - - - - - - - - - - - - - - -

  def manifest(id)
    manifest_src = saver.assert(manifest_read_command(id))
    json_parse(manifest_src)
  end

  # - - - - - - - - - - - - - - - - - - -

  def ran_tests(id, index, files, now, duration, stdout, stderr, status, colour, predicted='none')
    event_summary = {
      'index' => index,
      'time' => now,
      'colour' => colour,
      'duration' => duration,
      #'predicted' => predicted, # Not live yet
    }
    event_n = {
      'files' => files,
      'stdout' => stdout,
      'stderr' => stderr,
      'status' => status
    }
    saver.batch_assert([
      # The order of these commands matters.
      # A failing write_command() ensure the append_command() is not run.
      event_write_command(id, index, json_plain(event_n.merge(event_summary))),
      events_append_command(id, ",\n" + json_plain(event_summary))
    ])
  end

  # - - - - - - - - - - - - - - - - - - -

  def tipper_info(id, was_index, now_index)
    results = saver.batch_assert([
      events_read_command(id),
      event_read_command(id, was_index),
      event_read_command(id, now_index)
    ])
    events = json_parse('[' + results[0] + ']')
    was_files = json_parse(results[1])['files']
    now_files = json_parse(results[2])['files']
    [events,was_files,now_files]
  end

  # - - - - - - - - - - - - - - - - - - -

  def diff_info(id, was_index, now_index)
    results = saver.batch_assert([
      manifest_read_command(id),
      events_read_command(id),
      event_read_command(id, was_index),
      event_read_command(id, now_index)
    ])
    manifest = json_parse(results[0])
    events = json_parse('[' + results[1] + ']')
    was = json_parse(results[2])
    now = json_parse(results[3])
    [manifest,events,was,now]
  end

  # - - - - - - - - - - - - - - - - - - -

  def events(id)
    events_src = saver.assert(events_read_command(id))
    json_parse('[' + events_src + ']')
  end

  # - - - - - - - - - - - - - - - - - - -

  def event(id, index)
    if index === -1
      events_src = saver.assert(events_read_command(id))
      pos = events_src.rindex("\n") || 0
      index = json_parse(events_src[pos..-1])['index']
    end
    event_src = saver.assert(event_read_command(id, index))
    json_parse(event_src)
  end

  private

  include OjAdapter

  # - - - - - - - - - - - - - - - - - - - - - -
  # manifest
  #
  # In theory the manifest could store only the display_name
  # and exercise_name and be recreated, on-demand, from the relevant
  # start-point services. In practice it creates coupling, and it
  # doesn't work anyway, since start-point services change over time.

  def manifest_write_command(id, manifest_src)
    saver.write_command(manifest_filename(id), manifest_src)
  end

  def manifest_read_command(id)
    saver.read_command(manifest_filename(id))
  end

  # - - - - - - - - - - - - - - - - - - - - - -
  # events

  def events_write_command(id, event0_src)
    saver.write_command(events_filename(id), event0_src)
  end

  def events_append_command(id, eventN_src)
    saver.append_command(events_filename(id), eventN_src)
  end

  def events_read_command(id)
    saver.read_command(events_filename(id))
  end

  # - - - - - - - - - - - - - - - - - - - - - -
  # event

  def event_write_command(id, index, event_src)
    saver.write_command(event_filename(id,index), event_src)
  end

  def event_read_command(id, index)
    saver.read_command(event_filename(id,index))
  end

  # - - - - - - - - - - - - - -
  # names of dirs/files

  def manifest_filename(id)
    kata_id_path(id, 'manifest.json')
    # eg id == 'SyG9sT' ==> '/cyber-dojo/katas/Sy/G9/sT/manifest.json'
    # eg content ==> {"display_name":"Ruby, MiniTest",...}
  end

  def events_filename(id)
    kata_id_path(id, 'events.json')
    # eg id == 'SyG9sT' ==> '/cyber-dojo/katas/Sy/G9/sT/events.json'
    # eg content ==>
    # {"index":0,...,"event":"created"},
    # {"index":1,...,"colour":"red"},
    # {"index":2,...,"colour":"amber"},
  end

  def event_filename(id, index)
    kata_id_path(id, "#{index}.event.json")
    # eg id == 'SyG9sT', index == 2 ==> '/cyber-dojo/katas/Sy/G9/sT/2.event.json'
    # eg content ==>
    # {
    #   "files":{
    #     "hiker.rb":{"content":"......","truncated":false}
    #     ...
    #   },
    #   "stdout":{"content":"...","truncated":false},
    #   "stderr":{"content":"...","truncated":false},
    #   "status":1
    #   "index":2,
    #   "time":[2020,3,27,11,56,7,719235],
    #   "duration":1.064011,
    #   "colour":"amber"
    # }
  end

  include IdPather

  # - - - - - - - - - - - - - -

  def saver
    @externals.saver
  end

end
