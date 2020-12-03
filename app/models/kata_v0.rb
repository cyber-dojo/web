# frozen_string_literal: true
require_relative 'id_pather'
require_relative 'liner'
require_relative '../../lib/oj_adapter'

class Kata_v0

  def initialize(externals)
    @externals = externals
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
  include IdPather # kata_id_path

  # - - - - - - - - - - - - - - - - - - - - - -
  # events
  #
  # A cache of colours/time-stamps for all [test] events.
  # Helps optimize dashboard traffic-lights views.
  # Each event is stored as a single "\n" terminated line.
  # This is an optimization for ran_tests() which need only
  # append to the end of the file.

  def events_file_read_command(id)
    saver.file_read_command(events_filename(id))
  end

  # - - - - - - - - - - - - - - - - - - - - - -
  # event
  #
  # The visible-files are stored in a lined-format so they be easily
  # inspected on disk. Have to be unlined when read back.

  def event_file_read_command(id, index)
    saver.file_read_command(event_filename(id, index))
  end

  # - - - - - - - - - - - - - -
  # names of dirs/files

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

  def saver
    @externals.saver
  end

end
