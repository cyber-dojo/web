# frozen_string_literal: true

require_relative 'id_generator'
require_relative 'id_pather'
require_relative 'liner'
require_relative '../../lib/oj_adapter'

class Kata_v0

  def initialize(externals)
    @externals = externals
  end

  # - - - - - - - - - - - - - - - - - - -

  def create(manifest)
    files = manifest.delete('visible_files')
    id = manifest['id'] = IdGenerator.new(@externals).kata_id
    event0 = {
      'event' => 'created',
      'time' => manifest['created']
    }
    saver.assert_all([
      dir_make_command(id, 0),
      manifest_file_create_command(id, json_plain(manifest)),
      event_file_create_command(id, 0, json_plain(lined({ 'files' => files }))),
      events_file_create_command(id, json_plain(event0) + "\n")
    ])
    id
  end

  # - - - - - - - - - - - - - - - - - - -

  def manifest(id)
     manifest_src,event0_src = saver.assert_all([
      manifest_file_read_command(id),
      event_file_read_command(id, 0)
    ])
    manifest = json_parse(manifest_src)
    event0 = unlined(json_parse(event0_src))
    manifest['visible_files'] = event0['files']
    manifest
  end

  # - - - - - - - - - - - - - - - - - - -

  def ran_tests(id, index, files, stdout, stderr, status, summary)
    event_n = {
      'files' => files,
      'stdout' => stdout,
      'stderr' => stderr,
      'status' => status
    }
    saver.assert_all([
      # A failing create_command() ensure the append_command() is not run.
      dir_exists_command(id),
      dir_make_command(id, index),
      event_file_create_command(id, index, json_plain(lined(event_n))),
      events_file_append_command(id, json_plain(summary) + "\n")
    ])
  end

  # - - - - - - - - - - - - - - - - - - -

  def revert(id, index, files, stdout, stderr, status, summary)
    event_n = {
       'files' => files,
      'stdout' => stdout,
      'stderr' => stderr,
      'status' => status
    }
    saver.assert_all([
      # A failing create_command() ensure the append_command() is not run.
      dir_exists_command(id),
      dir_make_command(id, index),
      event_file_create_command(id, index, json_plain(lined(event_n))),
      events_file_append_command(id, json_plain(summary) + "\n")
    ])
  end

  # - - - - - - - - - - - - - - - - - - -

  def tipper_info(id, was_index, now_index)
    results = saver.assert_all([
      events_file_read_command(id),
      event_file_read_command(id, was_index),
      event_file_read_command(id, now_index)
    ])
    events = json_parse('[' + results[0].lines.join(',') + ']')
    was_files = unlined(json_parse(results[1]))['files']
    now_files = unlined(json_parse(results[2]))['files']
    [events,was_files,now_files]
  end

  # - - - - - - - - - - - - - - - - - - -

  def diff_info(id, was_index, now_index)
    results = saver.assert_all([
      manifest_file_read_command(id),
      events_file_read_command(id),
      event_file_read_command(id, was_index),
      event_file_read_command(id, now_index)
    ])
    manifest = json_parse(results[0])
    events = json_parse('[' + results[1].lines.join(',') + ']')
    was = unlined(json_parse(results[2]))
    now = unlined(json_parse(results[3]))
    [manifest,events,was,now]
  end

  # - - - - - - - - - - - - - - - - - - -

  def events(id)
    json_parse(events_json(id))
    # Alternative implementation, which profiling shows is slower.
    # events_src.lines.map { |line| json_parse(line) }
  end

  def events_json(id)
    events_src = saver.assert(events_file_read_command(id))
    '[' + events_src.lines.join(',') + ']'
  end

  # - - - - - - - - - - - - - - - - - - -

  def event(id, index)
    if index === -1
      events_src = saver.assert(events_file_read_command(id))
      index = events_src.count("\n") - 1
    end
    event_src = saver.assert(event_file_read_command(id, index))
    unlined(json_parse(event_src))
  end

  private

  include Liner
  include OjAdapter

  # - - - - - - - - - - - - - - - - - - - - - -

  def dir_make_command(id, *parts)
    saver.dir_make_command(dirname(id, *parts))
  end

  def dir_exists_command(id, *parts)
    saver.dir_exists_command(dirname(id, *parts))
  end

  # - - - - - - - - - - - - - - - - - - - - - -
  # manifest
  #
  # Extracts the visible_files from the manifest and
  # stores them as event-zero files. This allows a diff of the
  # first traffic-light but means manifest() has to recombine two
  # files. In theory the manifest could store only the display_name
  # and exercise_name and be recreated, on-demand, from the relevant
  # start-point services. In practice, it doesn't work because the
  # start-point services can change over time.

  def manifest_file_create_command(id, manifest_src)
    saver.file_create_command(manifest_filename(id), manifest_src)
  end

  def manifest_file_read_command(id)
    saver.file_read_command(manifest_filename(id))
  end

  # - - - - - - - - - - - - - - - - - - - - - -
  # events
  #
  # A cache of colours/time-stamps for all [test] events.
  # Helps optimize dashboard traffic-lights views.
  # Each event is stored as a single "\n" terminated line.
  # This is an optimization for ran_tests() which need only
  # append to the end of the file.

  def events_file_create_command(id, event0_src)
    saver.file_create_command(events_filename(id), event0_src)
  end

  def events_file_append_command(id, eventN_src)
    saver.file_append_command(events_filename(id), eventN_src)
  end

  def events_file_read_command(id)
    saver.file_read_command(events_filename(id))
  end

  # - - - - - - - - - - - - - - - - - - - - - -
  # event
  #
  # The visible-files are stored in a lined-format so they be easily
  # inspected on disk. Have to be unlined when read back.

  def event_file_create_command(id, index, event_src)
    saver.file_create_command(event_filename(id, index), event_src)
  end

  def event_file_read_command(id, index)
    saver.file_read_command(event_filename(id, index))
  end

  # - - - - - - - - - - - - - -
  # names of dirs/files

  def dirname(id, *parts)
    kata_id_path(id, *parts)
    # eg id == 'k5ZTk0', parts = [] ==> '/cyber-dojo/katas/k5/ZT/k0'
    # eg id == 'k5ZTk0', parts = [31] ==> '/cyber-dojo/katas/k5/ZT/k0/31'
  end

  def manifest_filename(id)
    kata_id_path(id, 'manifest.json')
    # eg id == 'k5ZTk0' ==> '/cyber-dojo/katas/k5/ZT/manifest.json'
    # eg content ==> {"display_name":"Ruby, MiniTest",...}
  end

  def events_filename(id)
    kata_id_path(id, 'events.json')
    # eg id == 'k5ZTk0' ==> '/cyber-dojo/katas/k5/ZT/events.json'
    # eg content ==>
    # {"event":"created","time":[2019,1,19,12,41,0,406370]}
    # {"colour":"red","time":[2019,1,19,12,45,19,994317],"duration":1.224763}
    # {"colour":"amber","time":[2019,1,19,12,45,26,76791],"duration":1.1275}
    # {"colour":"green","time":[2019,1,19,12,45,30,656924],"duration":1.072198}
  end

  def event_filename(id, index)
    kata_id_path(id, index, 'event.json')
    # eg id == 'k5ZTk0', index == 2 ==> '/cyber-dojo/katas/k5/ZT//2/event.json'
    # eg content ==>
    # {
    #   "files":{
    #     "hiker.rb":{"content":"......","truncated":false},
    #     ...
    #   },
    #   "stdout":{"content":"...","truncated":false},
    #   "stderr":{"content":"...","truncated":false},
    #   "status":1
    # }
  end

  include IdPather

  # - - - - - - - - - - - - - -

  def saver
    @externals.saver
  end

end
