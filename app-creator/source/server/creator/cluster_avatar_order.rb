module CreatorApp
  class ClusterAvatarOrder
    # The number of distinct avatars (animals) a saver group can hand out; each
    # is identified by an index in 0...AVATAR_COUNT.
    AVATAR_COUNT = 64

    # shuffle: turns one usage-count bucket into a random order, so
    # equally-used avatars are handed out unpredictably. Injectable so tests
    # are deterministic.
    def initialize(shuffle: ->(indexes) { indexes.shuffle })
      @shuffle = shuffle
    end

    # used_indexes: every avatar index in use across all of a cluster's groups,
    # one entry per use (so an index used in three groups appears three times).
    # Returns all AVATAR_COUNT indexes as a group_join candidate order: those
    # used fewest times cluster-wide come first (never-used before used-once,
    # and so on), each usage-count bucket independently shuffled. The saver
    # then joins on the first still-free index, so a cluster-scarce avatar is
    # preferred while any remain, degrading to reuse only past AVATAR_COUNT
    # joiners.
    def candidate_indexes(used_indexes)
      counts = used_indexes.tally
      (0...AVATAR_COUNT)
        .group_by { |index| counts.fetch(index, 0) }
        .sort_by { |count, _indexes| count }
        .flat_map { |_count, indexes| @shuffle.call(indexes) }
    end
  end
end
