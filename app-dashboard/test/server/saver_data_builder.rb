require 'json'
require 'net/http'

# Builds cyber-dojo entities (clusters, groups, avatars, traffic-lights)
# directly in the saver over HTTP, so a test can set up exactly the state it
# needs and then assert exact values rather than shapes. Mirrors
# bin/create_cluster_kata.rb.
module SaverDataBuilder

  # Creates a cluster with one child group per display-name, returning its id.
  def create_cluster(display_names)
    manifests = display_names.map { |name| group_manifest(name) }
    saver_post('cluster_create', { manifests: manifests })
  end

  # The ids of the cluster's child groups, one per LTF.
  def child_group_ids(cluster_id)
    saver_get('cluster_manifest', { id: cluster_id })['groups'].keys
  end

  # Creates a standalone group (in no cluster) for the display-name, returning
  # its id. Use this rather than a cluster when a test needs only one group: a
  # cluster requires 2..5 LTFs (see the saver's Cluster#create).
  def create_group(display_name)
    saver_post('group_create', { manifest: group_manifest(display_name) })
  end

  # Joins one avatar into the group, returning its kata id.
  def join_avatar(group_id)
    saver_post('group_join', { id: group_id })
  end

  # The writer's idempotency key the saver requires on every write. One notional
  # laptop makes all these writes, with tab_seq distinguishing them.
  LAPTOP_ID = '02cfdffb5c0c31221b837a153d1108e6cd19fd6cef11db27c8457a1e63caf46f'.freeze

  # The arguments every test-run event write shares, carrying the given summary.
  # tab_seq must differ per write, since laptop_id plus tab_seq is the saver's
  # idempotency key. The name must not start with test_ - minitest collects any
  # such method as a test and calls it with no arguments.
  def run_test_event_args(kata_id, summary, tab_seq)
    files = saver_get('kata_event', { id: kata_id, index: 0 })['files']
    {
      id: kata_id, files: files,
      stdout: file('2 tests, 0 failures'), stderr: file(''), status: 0,
      summary: summary, laptop_id: LAPTOP_ID, tab_seq: tab_seq
    }
  end

  # Runs the kata's tests once (a green traffic-light), giving the avatar a
  # non-creation event. The saver assigns the event's index (head + 1).
  def give_traffic_light(kata_id)
    saver_post('kata_ran_tests',
               run_test_event_args(kata_id, { 'colour' => 'green', 'predicted' => 'none' }, 1))
  end

  # A traffic-light whose event carries a prediction that turned out right.
  def give_predicted_light(kata_id)
    saver_post('kata_predicted_right',
               run_test_event_args(kata_id, { 'colour' => 'green', 'predicted' => 'green' }, 3))
  end

  # A traffic-light whose event carries the [id, index] it was reverted to.
  def give_reverted_light(kata_id)
    saver_post('kata_reverted',
               run_test_event_args(kata_id, { 'colour' => 'red', 'revert' => [kata_id, 1] }, 4))
  end

  # A traffic-light whose event carries what it was checked out from.
  def give_checked_out_light(kata_id)
    saver_post('kata_checked_out',
               run_test_event_args(kata_id,
                             { 'colour' => 'amber',
                               'checkout' => { 'id' => kata_id, 'index' => 1 } }, 5))
  end

  # Edits one of the kata's files, giving the avatar an inter-test event: a
  # non-zero index that is not a traffic-light. Only the detailed dashboard view
  # shows these.
  def edit_a_file(kata_id)
    files = saver_get('kata_event', { id: kata_id, index: 0 })['files']
    files['hiker.sh']['content'] += "\n# edited\n"
    saver_post('kata_file_edit', {
                 id: kata_id, files: files,
                 laptop_id: LAPTOP_ID, tab_seq: 2
               })
  end

  # A group manifest for the given LTF display-name, which must be a real one
  # (eg 'Bash, bats', 'Python, pytest', 'Ruby, MiniTest'). Every LTF shares the
  # same Bash/bats image and files; only the display-name differs. That mirrors
  # bin/create_cluster_kata.rb and holds for the same reason: one known
  # toolchain keeps generated runs reliable, and what these tests exercise is
  # per-LTF grouping rather than three distinct toolchains.
  def group_manifest(display_name)
    {
      'display_name' => display_name,
      'image_name' => 'cyberdojofoundation/bash_bats:53d0c9c',
      'filename_extension' => ['.sh'],
      'tab_size' => 4,
      'exercise' => 'Fizz Buzz',
      'version' => 2,
      'highlight_filenames' => [],
      'max_seconds' => 10,
      'visible_files' => {
        'hiker.sh' => file("echo hello\n"),
        'cyber-dojo.sh' => file("./hiker.sh\n")
      }
    }
  end

  # One entry of a manifest's visible_files.
  def file(content)
    { 'content' => content, 'truncated' => false }
  end

  # - - - - - - - - - - - - - - - - -

  # GETs the saver path, returning the value under its own key.
  def saver_get(path, args)
    saver_request(Net::HTTP::Get, path, args)
  end

  # POSTs to the saver path, returning the value under its own key.
  def saver_post(path, args)
    saver_request(Net::HTTP::Post, path, args)
  end

  # Sends one json request to the saver and unwraps its path-keyed response.
  def saver_request(method_class, path, args)
    host = ENV.fetch('CYBER_DOJO_SAVER_HOSTNAME', 'saver')
    port = ENV.fetch('CYBER_DOJO_SAVER_PORT', 4537).to_i
    uri = URI("http://#{host}:#{port}/#{path}")
    req = method_class.new(uri)
    req.content_type = 'application/json'
    req.body = JSON.generate(args)
    response = Net::HTTP.start(host, port) { |http| http.request(req) }
    JSON.parse(response.body)[path.to_s]
  end
end
