require_relative 'test_base'
require 'json'
require 'ostruct'

class ProbesTest < TestBase

  # - - - - - - - - - - - - - - - - -

  test 'p9r2b1', %w(
  | GET /alive? has status 200 and returns true, and nothing else
  ) do
    assert_probe_200('alive?') do |response|
      assert_equal ['alive?'], response.keys, response
      assert true?(response['alive?']), response
    end
  end

  # - - - - - - - - - - - - - - - - -

  test 'p9r2b2', %w(
  | when the saver is ready
  | GET /ready? has status 200 and returns true, and nothing else
  ) do
    assert_probe_200('ready?') do |response|
      assert_equal ['ready?'], response.keys, response
      assert true?(response['ready?']), response
    end
  end

  # - - - - - - - - - - - - - - - - -

  test 'p9r2b3', %w(
  | when the saver is not ready
  | GET /ready? has status 200 and returns false, and nothing else
  ) do
    externals.instance_exec { @saver = STUB_READY_FALSE }
    assert_probe_200('ready?') do |response|
      assert_equal ['ready?'], response.keys, response
      assert false?(response['ready?']), response
    end
  end

  # - - - - - - - - - - - - - - - - -

  test 'p9r2b4', %w(
  | GET /alive? is used by external k8s probes, so obeys Postel's Law
  | and ignores any passed arguments
  ) do
    assert_probe_200('alive?arg=unused') do |response|
      assert_equal ['alive?'], response.keys, response
      assert true?(response['alive?']), response
    end
  end

  # - - - - - - - - - - - - - - - - -

  test 'p9r2b5', %w(
  | GET /ready? is used by external k8s probes, so obeys Postel's Law
  | and ignores any passed arguments
  ) do
    assert_probe_200('ready?arg=unused') do |response|
      assert_equal ['ready?'], response.keys, response
      assert true?(response['ready?']), response
    end
  end

  # - - - - - - - - - - - - - - - - -

  test 'p9r2b6', %w(
  | GET /sha has status 200 and returns the 40-char lowercase git commit sha
  | baked into the image at build time, and nothing else
  ) do
    assert_probe_200('sha') do |response|
      assert_equal ['sha'], response.keys, response
      assert git_sha?(response['sha']), response['sha']
    end
  end

  private

  STUB_READY_FALSE = OpenStruct.new(ready?: false)

  # GETs the probe path as json, asserts 200 and no stray output, then yields
  # the parsed body.
  def assert_probe_200(path, &block)
    stdout, stderr = capture_io do
      get mounted_path(path), {}, { 'HTTP_ACCEPT' => 'application/json' }
    end
    assert status?(200), "status=#{status}"
    assert_equal '', stderr, :stderr
    assert_equal '', stdout, :stdout
    block.call(JSON.parse(last_response.body))
  end

  # True when obj is exactly true, rather than merely truthy.
  def true?(obj)
    obj.instance_of?(TrueClass)
  end

  # True when obj is exactly false, rather than merely falsy.
  def false?(obj)
    obj.instance_of?(FalseClass)
  end

  # True when str is a 40-character lowercase hex git commit sha.
  def git_sha?(str)
    str.instance_of?(String) &&
      str.size == 40 &&
      str.chars.all? { |ch| '0123456789abcdef'.include?(ch) }
  end
end
