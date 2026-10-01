require_relative 'test_base'
require_relative 'saver_data_builder'
require 'json'

class ActiveGroupsTest < TestBase
  include SaverDataBuilder

  # Cluster vntRcc is baked into the saver test data (see cluster_tabs_test.rb);
  # every one of its three child groups has avatars with traffic-lights.
  BAKED_CLUSTER_ID = 'vntRcc'
  BAKED_CHILD_IDS = %w[9aZUWE jUgkhB 9bYWLV].freeze
  # A standalone group (in no cluster), also baked in.
  STANDALONE_GROUP_ID = 'LyQpFr'

  # - - - - - - - - - - - - - - - - -

  test 'a6t1v1', %w(
  | GET /active_groups reports, per child group of a cluster, whether it has
  | any avatar with a non-creation event; a child that has only been joined
  | (no test run) is reported false, a child with a run is reported true
  ) do
    cluster_id = create_cluster(['Bash, bats', 'Python, pytest'])
    active_child, inactive_child = child_group_ids(cluster_id)
    give_traffic_light(join_avatar(active_child))
    join_avatar(inactive_child) # joined only - no run, so no traffic-light

    active = get_active_groups(cluster_id)
    assert_equal({ active_child => true, inactive_child => false }, active, active)
  end

  # - - - - - - - - - - - - - - - - -

  test 'a6t1v2', %w(
  | GET /active_groups for a cluster whose every child has traffic-lights
  | reports every child true
  ) do
    active = get_active_groups(BAKED_CLUSTER_ID)
    assert_equal BAKED_CHILD_IDS.to_h { |id| [id, true] }, active, active
  end

  # - - - - - - - - - - - - - - - - -

  test 'a6t1v3', %w(
  | GET /active_groups for a standalone group (in no cluster) reports nothing,
  | since a standalone group has no tabs to rotate through
  ) do
    assert_equal({}, get_active_groups(STANDALONE_GROUP_ID), :standalone)
  end

  # - - - - - - - - - - - - - - - - -

  test 'a6t1v4', %w(
  | GET /active_groups reports nothing when the saver cannot be reached, so an
  | auto-refreshing cluster dashboard simply refreshes in place rather than
  | breaking on a saver hiccup
  ) do
    saver = RaisingSaver.new
    externals.instance_exec { @saver = saver }

    assert_equal({}, get_active_groups(BAKED_CLUSTER_ID), :saver_unreachable)
  end

  private

  # Stands in for a saver that cannot be reached, so active_groups takes its
  # best-effort rescue path.
  class RaisingSaver
    def id_chain(_id)
      raise 'saver unreachable'
    end
  end

  # GETs /active_groups/<id> as json, asserts 200, and returns the parsed body.
  def get_active_groups(id)
    get mounted_path("active_groups/#{id}"), {}, { 'HTTP_ACCEPT' => 'application/json' }
    assert status?(200), "status=#{status}"
    JSON.parse(last_response.body)
  end
end
