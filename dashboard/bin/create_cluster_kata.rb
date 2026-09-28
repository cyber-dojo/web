# frozen_string_literal: true

# Connects to the saver (its port is reachable from inside the saver container)
# and creates a v2 cluster: a multi-LTF practice offering 3 LTFs of the same
# exercise (Fizz Buzz). Each of the 3 child groups gets 5 avatars joined, and
# each avatar gets 3-6 traffic-lights of random red/amber/green colours.
# Prints the cluster id on completion.
#
# This exercises the dashboard's cluster view: /dashboard/show/<cluster-id>
# resolves up to the cluster and renders one tab per child group.
#
# The three LTFs share the same Bash/bats files (only display_name differs) so
# the generated test runs are reliable; the point of the demo is the per-LTF
# tabs, not three distinct toolchains.

require 'json'
require 'net/http'
require 'securerandom'

if ARGV.include?('-h')
  puts <<~HELP
    Usage: ruby bin/create_cluster_kata.rb

    Creates a 3-LTF Fizz Buzz cluster in the running saver, with 5 avatars per
    child group (each with 3-6 random red/amber/green traffic-lights), and
    prints the cluster id.

    Example:
      ruby bin/create_cluster_kata.rb
  HELP
  exit 0
end

SAVER_HOST = 'localhost'
SAVER_PORT = ENV.fetch('CYBER_DOJO_SAVER_PORT', '4537').to_i

# The 3 LTFs the cluster offers (one child group each).
LTF_DISPLAY_NAMES = ['Bash, bats', 'Python, pytest', 'Ruby, MiniTest'].freeze

# Only this LTF carries progress_regexs, so the dashboard's per-tab progress
# button appears on this tab only and stays hidden on the other two - demoing
# that the button reflects the active child group's manifest, not the cluster.
# It is deliberately NOT the first (default) tab, so the button starts hidden
# and appears when you switch to this tab.
LTF_WITH_PROGRESS = 'Python, pytest'

PROGRESS_REGEXS = [
  '\\d+ tests, [1-9]\\d* failure',
  '\\d+ tests, 0 failures'
].freeze

AVATARS_PER_GROUP = 5
LIGHTS_PER_AVATAR = (3..6).freeze

# Each colour is produced by substituting the echo line in hiker.sh:
#   red:   echo "${n}" -> echo "WIBBLE"  (wrong output)
#   amber: echo "${n}" -> echo "${n      (bash syntax error)
#   green: echo "${n}"                   (correct, no substitution needed)
GREEN_LINE = 'echo "${n}"'
RED_LINE   = 'echo "WIBBLE"'
AMBER_LINE = 'echo "${n'

HIKER_SH = <<~BASH
  #!/bin/bash

  fizz_buzz()
  {
    local -r n=${1}
    if   [ $((n % 15)) -eq 0 ]; then echo 'FizzBuzz'
    elif [ $((n % 3))  -eq 0 ]; then echo 'Fizz'
    elif [ $((n % 5))  -eq 0 ]; then echo 'Buzz'
    else                              echo "${n}"
    fi
  }
BASH

TEST_HIKER_SH = <<~BASH
  #!/usr/bin/env bats

  source ./hiker.sh

  @test "1 gives 1" {
    [ "$(fizz_buzz 1)" = "1" ]
  }

  @test "3 gives Fizz" {
    [ "$(fizz_buzz 3)" = "Fizz" ]
  }
BASH

CYBER_DOJO_SH = "chmod 700 *.sh\n./test_hiker.sh\n"

README = <<~TEXT
  Write a program that prints the numbers from 1 to 100.
  But for multiples of three print "Fizz" instead of the number,
  for multiples of five print "Buzz", and for numbers which are
  multiples of both three and five print "FizzBuzz".
TEXT

RED_STDOUT = "1..2\nnot ok 1 1 gives 1\n" \
             "# (in test file ./test_hiker.sh, line 6)\n" \
             "#   `[ \"$(fizz_buzz 1)\" = \"1\" ]' failed\n" \
             "ok 2 3 gives Fizz\n\n2 tests, 1 failure"

GREEN_STDOUT = "1..2\nok 1 1 gives 1\nok 2 3 gives Fizz\n\n2 tests, 0 failures"

HIKER_LINE_FOR = {
  'red' => RED_LINE,
  'amber' => AMBER_LINE,
  'green' => GREEN_LINE
}.freeze

STDOUT_FOR = {
  'red' => RED_STDOUT,
  'amber' => '',
  'green' => GREEN_STDOUT
}.freeze

STDERR_FOR = {
  'red' => '',
  'amber' => "./hiker.sh: line 10: `${n': bad substitution",
  'green' => ''
}.freeze

STATUS_FOR = {
  'red' => 1,
  'amber' => 1,
  'green' => 0
}.freeze

# The manifest fields shared by every LTF; only display_name, visible_files and
# (optionally) progress_regexs differ per child group.
BASE_MANIFEST = {
  'image_name' => 'cyberdojofoundation/bash_bats:53d0c9c',
  'filename_extension' => ['.sh'],
  'tab_size' => 4,
  'exercise' => 'Fizz Buzz',
  'version' => 2,
  'highlight_filenames' => [],
  'max_seconds' => 10
}.freeze

# The four visible files every child group starts with (all LTFs share them).
def visible_files
  {
    'hiker.sh' => file(HIKER_SH),
    'test_hiker.sh' => file(TEST_HIKER_SH),
    'cyber-dojo.sh' => file(CYBER_DOJO_SH),
    'readme.txt' => file(README)
  }
end

# The v2 group manifest for one LTF child group. An LTF that does not support
# progress simply OMITS progress_regexs - it must not store an empty []. (The
# saver polyfills a missing key to [] on read, so the dashboard still hides the
# progress button for those tabs.)
def manifest_for(display_name, progress_regexs)
  manifest = BASE_MANIFEST.merge(
    'display_name' => display_name,
    'visible_files' => visible_files
  )
  manifest['progress_regexs'] = progress_regexs if progress_regexs
  manifest
end

def saver_get(path, args)
  saver_request(Net::HTTP::Get, path, args)
end

def saver_post(path, args)
  saver_request(Net::HTTP::Post, path, args)
end

def saver_request(method_class, path, args)
  uri = URI("http://#{SAVER_HOST}:#{SAVER_PORT}/#{path}")
  req = method_class.new(uri)
  req.content_type = 'application/json'
  req.body = JSON.generate(args)
  response = Net::HTTP.start(SAVER_HOST, SAVER_PORT) { |h| h.request(req) }
  JSON.parse(response.body)[path.to_s]
end

def file(content)
  { 'content' => content, 'truncated' => false }
end

def log_dot
  $stderr.print '.'
  $stderr.flush
end

# The kata_ran_tests payload for one run producing the given colour. laptop_id
# and tab_seq form the writer's (laptop_id, tab_seq, colour) idempotency key;
# the monotonic tab_seq stops same-colour runs colliding on that key.
def ran_tests_args(kata_id, files, hue, laptop_id, tab_seq)
  {
    id: kata_id, files: files,
    stdout: file(STDOUT_FOR[hue]),
    stderr: file(STDERR_FOR[hue]),
    status: STATUS_FOR[hue],
    summary: { 'colour' => hue, 'predicted' => 'none' },
    laptop_id: laptop_id,
    tab_seq: tab_seq
  }
end

# One avatar is one writer: a fixed laptop_id (a browser profile) plus a
# monotonic tab_seq advanced on every write, so same-colour writes never
# collide on the saver's (laptop_id, tab_seq, colour) idempotency key.
class Writer
  attr_reader :laptop_id

  # Mints a fresh browser-profile laptop_id; the tab counter starts at 0.
  def initialize
    @laptop_id = SecureRandom.hex(32)
    @tab_seq = 0
  end

  # Advances to and returns this writer's next tab_seq (its first write is 1).
  def next_tab_seq
    @tab_seq += 1
  end
end

# Runs the tests once for the writer, having substituted hiker.sh to produce
# the given colour.
def traffic_light(kata_id, files, original_hiker, hue, writer)
  files['hiker.sh']['content'] =
    original_hiker.sub(GREEN_LINE, HIKER_LINE_FOR[hue])
  args = ran_tests_args(kata_id, files, hue, writer.laptop_id,
                        writer.next_tab_seq)
  saver_post('kata_ran_tests', args)
  log_dot
end

# Joins one avatar into the group and gives it 3-6 random traffic-lights. The
# avatar is one writer, so its tab_seq counts its writes 1, 2, 3...
def create_avatar(group_id)
  kata_id = saver_post('group_join', { id: group_id })
  files = saver_get('kata_event', { id: kata_id, index: 0 })['files']
  original_hiker = files['hiker.sh']['content']
  writer = Writer.new
  rand(LIGHTS_PER_AVATAR).times do
    hue = %w[red amber green].sample
    traffic_light(kata_id, files, original_hiker, hue, writer)
  end
end

# Create the cluster (materializes one child group per LTF) and read back its
# child group ids.
manifests = LTF_DISPLAY_NAMES.map do |name|
  regexs = name == LTF_WITH_PROGRESS ? PROGRESS_REGEXS : nil
  manifest_for(name, regexs)
end
cluster_id = saver_post('cluster_create', { manifests: manifests })
group_ids = saver_get('cluster_manifest', { id: cluster_id })['groups'].keys

# Join AVATARS_PER_GROUP avatars into each child group.
group_ids.each do |group_id|
  AVATARS_PER_GROUP.times { create_avatar(group_id) }
end

$stderr.puts
puts cluster_id
