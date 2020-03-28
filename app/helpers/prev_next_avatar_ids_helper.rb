# frozen_string_literal: true

module PrevNextAvatarIdsHelper # mix-in

  module_function

  def prev_next_avatar_ids(id, group_events)
    # eg id = "Q55b8b"
    # eg group_events = {
    #      "EEJSkR" => { "index"=>15, "events"=>[0,1,2]   }, # 15 == fox
    #      "Q55b8b" => { "index"=>23, "events"=>[0,1,2,3] }, # 23 == jellyfish
    #      "w34rd5" => { "index"=> 2, "events"=>[0]       }, #  2 == bat
    #      ...
    #   }
    sorted = group_events
      .map { |k,v| [k, v['index'], v['events']] }
      .sort { |lhs,rhs| lhs[1] <=> rhs[1] }
      .select { |a| a[2].size > 1 }
    # eg sorted = [
    #      [ "EEJSkR", 15, [0,1,2]   ], # 15 == fox
    #      [ "Q55b8b", 23, [0,1,2,3] ], # 23 == jellyfish
    #      ...
    #   ]
    index = sorted.find_index { |a| a[0] === id } # eg 1

    if index-1 >= 0
      prev_avatar_id = sorted[index-1][0]
    else
      prev_avatar_id = ''
    end

    if index+1 < sorted.size
      next_avatar_id = sorted[index+1][0]
    else
      next_avatar_id = ''
    end

    [ prev_avatar_id, next_avatar_id ]
  end

end
