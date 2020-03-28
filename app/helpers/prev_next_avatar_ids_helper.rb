# frozen_string_literal: true

module PrevNextAvatarIdsHelper # mix-in

  module_function

  def prev_next_avatar_ids(id, katas_indexes)
    # eg id =
    # eg kata_indexes =
    # [
    #   ['w34rd5', 2 ], #  2 == bat
    #   ['G2ws77',15 ], # 15 == fox
    #   ['SyG9sT',23 ], # 23 == jellyfish
    #   ['TZ6f29',24 ] # 24 == kangaroo
    #   ...
    # ]
    index = katas_indexes.find_index{|kid,| kid === id }

    if index-1 >= 0
      prev_avatar_id = katas_indexes[index-1][0]
    else
      prev_avatar_id = ''
    end

    if index+1 < katas_indexes.size
      next_avatar_id = katas_indexes[index+1][0]
    else
      next_avatar_id = ''
    end

    [ prev_avatar_id, next_avatar_id ]
  end

end
