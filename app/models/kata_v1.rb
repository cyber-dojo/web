# frozen_string_literal: true

require_relative 'id_generator'
require_relative 'id_pather'
require_relative 'saver_asserter'
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
#    a create_cmd() in its saver.batch call.
#    was     /cyber-dojo/katas/e3/T6/K2/0/event.json
#    now     /cyber-dojo/katas/e3/T6/K2/0.event.json

class Kata_v1

  def initialize(externals)
    @externals = externals
  end

  # - - - - - - - - - - - - - - - - - - -

  def create(manifest)
    id = manifest['id'] = generate_id
    manifest['version'] = 1
    event_summary = {
      'index' => 0,
      'time' => manifest['created'],
      'event' => 'created'
    }
    event0 = {
      'files' => manifest['visible_files']
    }
    saver_assert_batch(
      manifest_write_cmd(id, json_plain(manifest)),
      events_write_cmd(id, json_plain(event_summary)),
      event_write_cmd(id, 0, json_plain(event0.merge(event_summary)))
    )
    id
  end

  # - - - - - - - - - - - - - - - - - - -

  def manifest(id)
    manifest_src = saver_assert(manifest_read_cmd(id))
    json_parse(manifest_src)
  end

  # - - - - - - - - - - - - - - - - - - -

  def ran_tests(id, index, files, now, duration, stdout, stderr, status, colour)
    event_summary = {
      'index' => index,
      'time' => now,
      'duration' => duration,
      'colour' => colour
    }
    event_n = {
      'files' => files,
      'stdout' => stdout,
      'stderr' => stderr,
      'status' => status
    }
    saver_assert_batch(
      events_append_cmd(id, ',' + json_plain(event_summary)),
      event_write_cmd(id, index, json_plain(event_n.merge(event_summary)))
    )
  end

  # - - - - - - - - - - - - - - - - - - -

  def events(id)
    events_src = saver_assert(events_read_cmd(id))
    json_parse('[' + events_src + ']')
  end

  # - - - - - - - - - - - - - - - - - - -

  def event(id, index)
    if index === -1
      index = events(id)[-1]['index']
    end
    event_src = saver_assert(event_read_cmd(id, index))
    json_parse(event_src)
  end

  private

  include IdPather
  include OjAdapter
  include SaverAsserter

  # - - - - - - - - - - - - - - - - - - - - - -

  def generate_id
    id_generator = IdGenerator.new(@externals)
    42.times.find do
      id = id_generator.id
      if saver.create(id_path(id))
        break id
      end
    end
  end

  # - - - - - - - - - - - - - - - - - - - - - -
  # manifest
  #
  # In theory the manifest could store only the display_name
  # and exercise_name and be recreated, on-demand, from the relevant
  # start-point services. In practice it creates coupling, and it
  # doesn't work anyway, since start-point services change over time.

  def manifest_write_cmd(id, manifest_src)
    ['write', manifest_filename(id), manifest_src]
  end

  def manifest_read_cmd(id)
    ['read', manifest_filename(id)]
  end

  def manifest_filename(id)
    id_path(id, 'manifest.json')
  end

  # - - - - - - - - - - - - - - - - - - - - - -
  # events

  def events_write_cmd(id, event0_src)
    ['write', events_filename(id), event0_src]
  end

  def events_append_cmd(id, eventN_src)
    ['append', events_filename(id), eventN_src]
  end

  def events_read_cmd(id)
    ['read', events_filename(id)]
  end

  def events_filename(id)
    id_path(id, 'events.json')
  end

  # - - - - - - - - - - - - - - - - - - - - - -
  # event

  def event_write_cmd(id, index, event_src)
    ['write', event_filename(id,index), event_src]
  end

  def event_read_cmd(id, index)
    ['read', event_filename(id,index)]
  end

  def event_filename(id, index)
    id_path(id, "#{index}.event.json")
  end

  # - - - - - - - - - - - - - -

  def id_path(id, *parts)
    kata_id_path(id, *parts)
  end

  # - - - - - - - - - - - - - -

  def saver
    @externals.saver
  end

end
