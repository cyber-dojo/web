require_relative 'creator_test_base'
require_source 'cluster_avatar_order'

class ClusterAvatarOrderTest < CreatorTestBase

  # An injected shuffle that does not reorder, so bucket contents stay in
  # ascending index order and assertions can name the exact expected array.
  IDENTITY = ->(indexes) { indexes }

  # - - - - - - - - - - - - - - - - -

  qtest Av0rd1: %w[
    |with no avatars used anywhere in the cluster
    |every one of the 64 indexes sits in the single count==0 bucket
    |so the order is all 64 indexes
  ] do
    order = ClusterAvatarOrder.new(shuffle: IDENTITY).candidate_indexes([])
    assert_equal (0...64).to_a, order, order
  end

  # - - - - - - - - - - - - - - - - -

  qtest Av0rd2: %w[
    |indexes used once cluster-wide sink below the never-used indexes
    |and used-twice sink below used-once
    |ties within a usage-count bucket keep the injected (identity) order
  ] do
    # index 3 used twice, index 1 used once, all others zero.
    used = [1, 3, 3]
    order = ClusterAvatarOrder.new(shuffle: IDENTITY).candidate_indexes(used)
    zero_bucket = (0...64).to_a - [1, 3]
    assert_equal zero_bucket + [1] + [3], order, order
  end

  # - - - - - - - - - - - - - - - - -

  qtest Av0rd3: %w[
    |whatever the usage counts
    |the result is always a permutation of all 64 avatar indexes
    |(nothing dropped, nothing duplicated) even with a real shuffle
  ] do
    used = [0, 0, 5, 5, 5, 40]
    order = ClusterAvatarOrder.new.candidate_indexes(used)
    assert_equal (0...64).to_a, order.sort, order
  end

end
