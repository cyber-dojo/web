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
    # TODO: Description of problem...
    # Suppose two laptops are in as the same animal and they are
    # *not* keeping sync with browser refreshes. What happens is this:
    # lion-1 gets (say)  [red, amber]
    # Saver's state is
    #   events.json
    #     {"index":0,...,"event":"created"},
    #     {"index":1,...,"colour":"red"},
    #     {"index":2,...,"colour":"amber"},
    #   0.event.json
    #   1.event.json
    #   2.event.json
    #
    # Now, suppose lion-2 presses their [test] and gets a green.
    # On the web service, a Saver exception has arisen (and been swallowed)
    # because the event_write_cmd() returned false (since a file
    # called 1.event.json already exists). However, the preceeding
    # events_append_cmd() call has succeeded...
    # Saver's state is now:
    #   events.json
    #     {"index":0,...,"event":"created"},
    #     {"index":1,...,"colour":"red"},
    #     {"index":2,...,"colour":"amber"},
    #     {"index":1,...,"colour":"green"}, <----- appended
    #   0.event.json
    #   1.event.json <--- still the original from lion-1
    #   2.event.json
    #
    # If you now looked at a review-page (for either lion) you would see
    # three traffic-lights [red,amber,green], and *two* of them will be
    # marked as current (with an underbar).
    #
    # The solution is
    #   1) Add a saver.batch_assert() which stops (and raises) on the
    #      first command that returns false.
    #   2) Swap the order of these two cmd's
    #
    # It should then be possible to inspect the fine details of the
    # exception to determine if it is arising from an attempt to create
    # a file that *already* exists.
    # The Saver exception could be allowed to reach the browser
    # and the lion presented with information saying...
    #   o) failed to *save* this traffic-light
    #   o) there is more than one lion!
    #   o) info about how to do browser refreshing...
    saver_assert_batch(
      events_append_cmd(id, ",\n" + json_plain(event_summary)),
      event_write_cmd(id, index, json_plain(event_n.merge(event_summary)))
    )
  end

  # - - - - - - - - - - - - - - - - - - -

  def tipper_info(id, was_index, now_index)
    results = saver_assert_batch(
      events_read_cmd(id),
      event_read_cmd(id, was_index),
      event_read_cmd(id, now_index)
    )
    events = json_parse('[' + results[0] + ']')
    was_files = json_parse(results[1])['files']
    now_files = json_parse(results[2])['files']
    [events,was_files,now_files]
  end

  # - - - - - - - - - - - - - - - - - - -

  def diff_info(id, was_index, now_index)
    results = saver_assert_batch(
      manifest_read_cmd(id),
      events_read_cmd(id),
      event_read_cmd(id, was_index),
      event_read_cmd(id, now_index)
    )
    manifest = json_parse(results[0])
    events = json_parse('[' + results[1] + ']')
    was = json_parse(results[2])
    now = json_parse(results[3])
    [manifest,events,was,now]
  end

  # - - - - - - - - - - - - - - - - - - -

  def events(id)
    events_src = saver_assert(events_read_cmd(id))
    json_parse('[' + events_src + ']')
  end

  # - - - - - - - - - - - - - - - - - - -

  def event(id, index)
    if index === -1
      events_src = saver_assert(events_read_cmd(id))
      pos = events_src.rindex("\n") || 0
      index = json_parse(events_src[pos..-1])['index']
    end
    event_src = saver_assert(event_read_cmd(id, index))
    json_parse(event_src)
  end

  private

  include IdPather
  include OjAdapter
  include SaverAsserter

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
