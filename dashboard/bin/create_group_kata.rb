# frozen_string_literal: true

# Connects to the saver (its port is exposed to the host) and creates a v2
# group kata: Bash, bats / Fizz Buzz, with 16 avatars joined.
# Each avatar gets a random number of test runs with random traffic-light
# colours.
# Prints the group ID on completion.

require 'json'
require 'net/http'
require 'securerandom'

COUNT        = ARGV.fetch(0, '3').to_i
AVATAR_COUNT = ARGV.fetch(1, '16').to_i
SAVER_HOST   = 'localhost'
SAVER_PORT   = ENV.fetch('CYBER_DOJO_SAVER_PORT', '4537').to_i

# Each colour is produced by substituting the echo line in hiker.sh:
#   red:   echo "${n}" -> echo "WIBBLE"  (wrong output)
#   amber: echo "${n}" -> echo "${n      (bash syntax error)
#   green: echo "${n}"                   (correct, no substitution needed)
RED_LINE     = 'echo "WIBBLE"'
AMBER_LINE   = 'echo "${n'
GREEN_LINE = 'echo "${n}"'

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

  @test "5 gives Buzz" {
    [ "$(fizz_buzz 5)" = "Buzz" ]
  }

  @test "15 gives FizzBuzz" {
    [ "$(fizz_buzz 15)" = "FizzBuzz" ]
  }
BASH

CYBER_DOJO_SH = "chmod 700 *.sh\n./test_hiker.sh\n"

BATS_HELP = "\nbats help is online at\nhttps://github.com/bats-core/bats-core#usage\n"

README = <<~TEXT
  Write a program that prints the numbers from 1 to 100.
  But for multiples of three print "Fizz" instead of the number,
  for multiples of five print "Buzz", and for numbers which are
  multiples of both three and five print "FizzBuzz".

  Sample output:
  1
  2
  Fizz
  4
  Buzz
  Fizz
  7
  8
  Fizz
  Buzz
  11
  Fizz
  13
  14
  FizzBuzz
  16
  17
  Fizz
  19
  Buzz
  ... etc up to 100
TEXT

RED_STDOUT = "1..4\nnot ok 1 1 gives 1\n" \
             "# (in test file ./test_hiker.sh, line 6)\n" \
             "#   `[ \"$(fizz_buzz 1)\" = \"1\" ]' failed\n" \
             "ok 2 3 gives Fizz\nok 3 5 gives Buzz\n" \
             "ok 4 15 gives FizzBuzz\n\n4 tests, 1 failure"

GREEN_STDOUT = "1..4\nok 1 1 gives 1\nok 2 3 gives Fizz\nok 3 5 gives Buzz\n" \
               "ok 4 15 gives FizzBuzz\n\n4 tests, 0 failures"

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

MANIFEST = {
  'display_name' => 'Bash, bats',
  'image_name' => 'cyberdojofoundation/bash_bats:53d0c9c',
  'filename_extension' => ['.sh'],
  'tab_size' => 4,
  'visible_files' => {
    'hiker.sh' => { 'content' => HIKER_SH, 'truncated' => false },
    'test_hiker.sh' => { 'content' => TEST_HIKER_SH, 'truncated' => false },
    'cyber-dojo.sh' => { 'content' => CYBER_DOJO_SH, 'truncated' => false },
    'bats_help.txt' => { 'content' => BATS_HELP, 'truncated' => false },
    'readme.txt' => { 'content' => README, 'truncated' => false }
  },
  'exercise' => 'Fizz Buzz',
  'version' => 2,
  'highlight_filenames' => [],
  'max_seconds' => 10,
  'progress_regexs' => [
    '\\d+ tests, [1-9]\\d* failure',
    '\\d+ tests, 0 failures'
  ]
}.freeze

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

def colour(hue)
  { 'colour' => hue, 'predicted' => 'none' }
end

def log_dot
  $stderr.print '.'
  $stderr.flush
end

# laptop_id and tab_seq form the writer's (laptop_id, tab_seq, colour)
# idempotency key; the monotonic tab_seq stops same-colour runs colliding on it.
def ran_tests_args(id, files, hue, laptop_id, tab_seq)
  {
    id: id, files: files,
    stdout: file(STDOUT_FOR[hue]),
    stderr: file(STDERR_FOR[hue]),
    status: STATUS_FOR[hue],
    summary: colour(hue),
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

def traffic_light(id, files, original_hiker, hue, writer)
  files['hiker.sh']['content'] =
    original_hiker.sub(GREEN_LINE, HIKER_LINE_FOR[hue])
  args = ran_tests_args(id, files, hue, writer.laptop_id, writer.next_tab_seq)
  saver_post('kata_ran_tests', args)
  log_dot
end

COMMENT_LINE = '# ...'

# Each edit is a distinct write, so the writer's tab_seq advances per edit.
# Appends a comment to the named file and posts that edit as one write.
def append_comment(id, files, filename, writer)
  files[filename]['content'] += "#{COMMENT_LINE}\n"
  saver_post('kata_file_edit',
             { id: id, files: files,
               laptop_id: writer.laptop_id, tab_seq: writer.next_tab_seq })
  log_dot
end

def extra_file_edits(id, files, writer)
  rand(1..2).times do
    append_comment(id, files, 'hiker.sh', writer)
    append_comment(id, files, 'test_hiker.sh', writer)
  end
end

def rag_cycle(id, files, original_hiker, writer)
  rand(1..4).times do
    extra_file_edits(id, files, writer) if rand < 0.6
    traffic_light(id, files, original_hiker, %w[red amber green].sample, writer)
  end
end

# One avatar is one writer; its tab_seq counts every write across all its
# cycles.
def create_avatar(gid, count)
  id = saver_post('group_join', { id: gid })
  files = saver_get('kata_event', { id: id, index: 0 })['files']
  original_hiker = files['hiker.sh']['content']
  avatar_count = [1, (count / 2) + rand(count + 1)].max
  writer = Writer.new
  avatar_count.times { rag_cycle(id, files, original_hiker, writer) }
end

gid = saver_post('group_create', { manifest: MANIFEST })
actual_avatar_count = [1, (AVATAR_COUNT / 2) + rand(AVATAR_COUNT + 1)].max
actual_avatar_count.times { create_avatar(gid, COUNT) }
$stderr.puts
puts gid
