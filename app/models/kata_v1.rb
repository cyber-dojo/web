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
#    This improves robustness when there are Saver outages.
#    For example index==-1.
#    was    { ... } # 0
#           { ... } # 1
#    then 2-23 outage
#           { ... } # 24
#    now    { ..., "index" => 0 }
#           { ..., "index" => 1 }
#           { ..., "index" => 24 }
# 7. No longer uses separate dir for each event file.
#    This makes ran_tests() faster as it no longer needs
#    a create_command() in its saver.assert_all() call.
#    was     /cyber-dojo/katas/e3/T6/K2/0/event.json
#    now     /cyber-dojo/katas/e3/T6/K2/0.event.json

class Kata_v1

  def initialize(externals)
    @externals = externals
  end

  # - - - - - - - - - - - - - - - - - - -

  def events(id)
    json_parse(events_json(id))
  end

  def events_json(id)
    events_src = saver.assert(events_file_read_command(id))
    '[' + events_src + ']'
  end

  # - - - - - - - - - - - - - - - - - - -

  def event(id, index)
    if index === -1
      events_src = saver.assert(events_file_read_command(id))
      pos = events_src.rindex("\n") || 0
      index = json_parse(events_src[pos..-1])['index']
    end
    event_src = saver.assert(event_file_read_command(id, index))
    json_parse(event_src)
  end

  private

  include OjAdapter

  # - - - - - - - - - - - - - - - - - - - - - -
  # events

  def events_file_read_command(id)
    saver.file_read_command(events_filename(id))
  end

  # - - - - - - - - - - - - - - - - - - - - - -
  # event

  def event_file_read_command(id, index)
    saver.file_read_command(event_filename(id,index))
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
    #     "hiker.rb":{"content":"......","truncated":false},
    #     ...
    #   },
    #   "stdout":{"content":"...","truncated":false},
    #   "stderr":{"content":"...","truncated":false},
    #   "status":1,
    #   "index":2,
    #   "time":[2020,3,27,11,56,7,719235],
    #   "duration":1.064011,
    #   "colour":"amber"
    # }
  end

  include IdPather # kata_id_path

  # - - - - - - - - - - - - - -

  def saver
    @externals.saver
  end

end
