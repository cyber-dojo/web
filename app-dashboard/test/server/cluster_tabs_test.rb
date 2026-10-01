require_relative 'test_base'

class ClusterTabsTest < TestBase

  # Cluster vntRcc is baked into the saver test data by
  # bin/create_cluster_data.sh and tar-piped in by copy_in_saver_test_data().
  # It has three child groups (one per LTF), in this manifest order:
  #   9aZUWE "Bash, bats"      (first)
  #   jUgkhB "Python, pytest"
  #   9bYWLV "Ruby, MiniTest"
  CLUSTER_ID = 'vntRcc'

  test 'c1u5b1', %w(
  | a bare cluster id resolves up to the cluster: the show page renders
  | one tab per child group, first child active by default (line 83 nil-side)
  ) do
    html = show_html(CLUSTER_ID)
    assert_includes html, 'id="cluster-tabs"', html
    assert_includes html, 'data-group-id="9aZUWE"', html
    assert_includes html, 'data-group-id="jUgkhB"', html
    assert_includes html, 'data-group-id="9bYWLV"', html
    assert_includes html, 'Bash, bats', html
    assert_includes html, 'Python, pytest', html
    assert_includes html, 'Ruby, MiniTest', html
    assert_equal '9aZUWE', active_tab_id(html), html
  end

  test 'c1u5b2', %w(
  | a child-group id inside a cluster redirects to the cluster's own URL,
  | carrying that child as group_id so it stays the active tab
  ) do
    get mounted_path('show/9bYWLV'), {}, { 'HTTP_ACCEPT' => 'text/html' }
    assert status?(302), "status=#{status}"
    expected = mounted_path("show/#{CLUSTER_ID}?group_id=9bYWLV")
    assert_equal expected, redirect_location
  end

  test 'c1u5b3', %w(
  | a standalone group id (in no cluster) renders no cluster tabs (else branch)
  ) do
    html = show_html('LyQpFr')
    refute_includes html, 'id="cluster-tabs"', html
  end

  test 'c1u5b4', %w(
  | a group_id query param inside a cluster selects that child as the active
  | tab, overriding the bare-cluster-id default of the first child
  ) do
    html = show_html(CLUSTER_ID, group_id: 'jUgkhB')
    assert_includes html, 'id="cluster-tabs"', html
    assert_equal 'jUgkhB', active_tab_id(html), html
  end

  test 'c1u5b5', %w(
  | a group_id query param that names no child of the cluster is ignored:
  | the active tab falls back to the first child (never an absent tab)
  ) do
    html = show_html(CLUSTER_ID, group_id: 'nosuch')
    assert_includes html, 'id="cluster-tabs"', html
    assert_equal '9aZUWE', active_tab_id(html), html
  end

  test 'c1u5b6', %w(
  | the redirect to the cluster URL keeps the other query params, so eg a
  | chosen sort survives the hop
  ) do
    get mounted_path('show/9bYWLV'), { sort_by: 'lights' }, { 'HTTP_ACCEPT' => 'text/html' }
    assert status?(302), "status=#{status}"
    expected = mounted_path("show/#{CLUSTER_ID}?sort_by=lights&group_id=9bYWLV")
    assert_equal expected, redirect_location
  end

  # - - - - - - - - - - - - - - - - -

  test 'c1u5b7', %w(
  | an id resolving to neither a cluster nor a group - a standalone kata - is
  | rendered as a single group keyed on the requested id itself, with no tabs
  ) do
    saver = KataOnlyChainSaver.new
    externals.instance_exec { @saver = saver }

    html = show_html('kAtA01')
    assert_includes html, 'let _groupId = "kAtA01";', html
    assert_includes html, 'cd.tabs = () => [];', html
  end

  private

  # Stands in for the saver, answering an id-chain holding neither a cluster nor
  # a group, which is what a standalone kata resolves to.
  class KataOnlyChainSaver
    def id_chain(id)
      [{ 'type' => 'kata', 'id' => id }]
    end
  end

  # The Location header of the last response.
  def redirect_location
    last_response.headers['Location']
  end

  # GETs /show/<id> as html, asserts a 200, and returns the response body.
  def show_html(id, params = {})
    get mounted_path("show/#{id}"), params, { 'HTTP_ACCEPT' => 'text/html' }
    assert status?(200), "status=#{status}"
    last_response.body
  end

  # The group id of the tab currently marked cluster-tab-active, or nil.
  def active_tab_id(html)
    m = html.match(/cluster-tab-active"\s*data-group-id="([^"]+)"/m)
    m && m[1]
  end
end
