# frozen_string_literal: true

require_relative 'liner'
require_relative '../../lib/oj_adapter'
require_relative '../services/saver_exception'

class Kata_v1

  def initialize(externals)
    @externals = externals
  end

  # - - - - - - - - - - - - - - - - - - -

  def exists?(id)
    saver.exists?(id_path(id))
  end

  # - - - - - - - - - - - - - - - - - - -

  def create(manifest)
    files = manifest.delete('visible_files')
    id = manifest['id'] = generate_id
    event0 = {
      'event' => 'created',
      'time' => manifest['created']
    }
    saver.batch([
      create_cmd(id, 0),
      manifest_write_cmd(id, json_plain(manifest)),
      event_write_cmd(id, 0, json_plain(lined({ 'files' => files }))),
      events_write_cmd(id, json_plain(event0) + "\n")
    ])
    # TODO: unless result === [true]*4
    id
  end

  # - - - - - - - - - - - - - - - - - - -

  def manifest(id)
    manifest_src,event0_src = saver.batch([
      manifest_read_cmd(id),
      event_read_cmd(id, 0)
    ])
    if [manifest_src,event0_src].include?(nil)
      fail invalid('id', id)
    end
    manifest = json_parse(manifest_src)
    event0 = unlined(json_parse(event0_src))
    manifest['visible_files'] = event0['files']
    manifest
  end

  # - - - - - - - - - - - - - - - - - - -

  def ran_tests(id, index, files, now, duration, stdout, stderr, status, colour)
    unless index >= 1
      fail invalid('index', index)
    end
    event_n = {
      'files' => files,
      'stdout' => stdout,
      'stderr' => stderr,
      'status' => status
    }
    event_summary = {
      'colour' => colour,
      'time' => now,
      'duration' => duration
    }
    result = saver.batch([
      exists_cmd(id),
      create_cmd(id, index),
      event_write_cmd(id, index, json_plain(lined(event_n))),
      events_append_cmd(id, json_plain(event_summary) + "\n")
    ])
    unless result[0]
      fail invalid('id', id)
    end
    unless result[1]
      fail invalid('index', index)
    end
    nil
  end

  # - - - - - - - - - - - - - - - - - - -

  def events(id)
    events_src = saver.send(*events_read_cmd(id))
    if events_src.nil?
      fail invalid('id', id)
    end
    json_parse('[' + events_src.lines.join(',') + ']')
    # Alternative implementation, which profiling shows is slower.
    # events_src.lines.map { |line| json_parse(line) }
  end

  # - - - - - - - - - - - - - - - - - - -

  def event(id, index)
    if index === -1
      events_src = saver.send(*events_read_cmd(id))
      if events_src.nil?
        fail invalid('id', id)
      end
      index = events_src.count("\n") - 1
    end
    event_src = saver.send(*event_read_cmd(id, index))
    if event_src.nil?
      fail invalid('index', index)
    end
    unlined(json_parse(event_src))
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

  def id_path(id, *parts)
    # Using 2/2/2 split.
    # See https://github.com/cyber-dojo/id-split-timer
    args = ['', 'katas', id[0..1], id[2..3], id[4..5]]
    args += parts.map(&:to_s)
    File.join(*args)
  end

  # - - - - - - - - - - - - - - - - - - - - - -

  def create_cmd(id, *parts)
    ['create', id_path(id, *parts)]
  end

  def exists_cmd(id, *parts)
    ['exists?', id_path(id, *parts)]
  end

  # - - - - - - - - - - - - - - - - - - - - - -
  # manifest
  #
  # create() extracts the visible_files from the manifest and
  # stores them as event-zero files. This allows a diff of the
  # first traffic-light but means manifest() has to recombine two
  # files. In theory the manifest could store only the display_name
  # and exercise_name and be recreated, on-demand, from the relevant
  # start-point services. In practice, it doesn't work because the
  # start-point services can change over time.

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
  #
  # A cache of colours/time-stamps for all [test] events.
  # Helps optimize dashboard traffic-lights views.
  # Each event is stored as a single "\n" terminated line.
  # This is an optimization for ran_tests() which need only
  # append to the end of the file.

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
  #
  # The visible-files are stored in a lined-format so they be easily
  # inspected on disk. Have to be unlined when read back.

  def event_write_cmd(id, index, event_src)
    ['write', event_filename(id, index), event_src]
  end

  def event_read_cmd(id, index)
    ['read', event_filename(id, index)]
  end

  def event_filename(id, index)
    id_path(id, index, 'event.json')
  end

  # - - - - - - - - - - - - - -

  def invalid(name, value)
    SaverException.new(json_pretty({
      "message" => "#{name}:invalid:#{value}"
    }))
  end

  def saver
    @externals.saver
  end

  def id_generator
    @externals.id_generator
  end

end
