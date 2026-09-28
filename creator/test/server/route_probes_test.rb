require_relative 'creator_test_base'
require 'ostruct'

class RouteProbesTest < CreatorTestBase

  # - - - - - - - - - - - - - - - - -
  # 200
  # - - - - - - - - - - - - - - - - -

  qtest a86C15: %w[
    |GET/alive?
    |has status 200
    |returns true
    |and nothing else
  ] do
    assert_get_200_json(path = 'alive?') do |response|
      assert_equal [path], response.keys, "keys:#{last_response.body}:"
      assert true?(response[path]), "true?:#{last_response.body}:"
    end
  end

  # - - - - - - - - - - - - - - - - -

  qtest a86D15: %w[
    |when all http-proxy are ready
    |GET/ready?
    |has status 200
    |returns true
    |and nothing else
  ] do
    assert_get_200_json(path = 'ready?') do |response|
      assert_equal [path], response.keys, "keys:#{last_response.body}:"
      assert true?(response[path]), "true?:#{last_response.body}:"
    end
  end

  # - - - - - - - - - - - - - - - - -

  qtest a86E15: %w[
    |when custom_start_points http-proxy is not ready
    |GET/ready?
    |has status 200
    |returns false
    |and nothing else
  ] do
    externals.instance_exec { @custom_start_points = STUB_READY_FALSE }
    assert_get_200_json(path = 'ready?') do |response|
      assert_equal [path], response.keys, "keys:#{last_response.body}:"
      assert false?(response[path]), "false?:#{last_response.body}:"
    end
  end

  qtest a86E16: %w[
    |when exercises_start_points http-proxy is not ready
    |GET/ready?
    |has status 200
    |returns false
    |and nothing else
  ] do
    externals.instance_exec { @exercises_start_points = STUB_READY_FALSE }
    assert_get_200_json(path = 'ready?') do |response|
      assert_equal [path], response.keys, "keys:#{last_response.body}:"
      assert false?(response[path]), "false?:#{last_response.body}:"
    end
  end

  qtest a86E17: %w[
    |when languages_start_points http-proxy is not ready
    |GET/ready?
    |has status 200
    |returns false
    |and nothing else
  ] do
    externals.instance_exec { @languages_start_points = STUB_READY_FALSE }
    assert_get_200_json(path = 'ready?') do |response|
      assert_equal [path], response.keys, "keys:#{last_response.body}:"
      assert false?(response[path]), "false?:#{last_response.body}:"
    end
  end

  qtest a86E19: %w[
    |when runner http-proxy is not ready
    |GET/ready?
    |has status 200
    |returns false
    |and nothing else
  ] do
    externals.instance_exec { @runner = STUB_READY_FALSE }
    assert_get_200_json(path = 'ready?') do |response|
      assert_equal [path], response.keys, "keys:#{last_response.body}:"
      assert false?(response[path]), "false?:#{last_response.body}:"
    end
  end

  # - - - - - - - - - - - - - - - - -

  qtest a86F15: %w[
    |when saver http-proxy is not ready
    |GET/ready?
    |has status 200
    |returns false
    |and nothing else
  ] do
    externals.instance_exec { @saver = STUB_READY_FALSE }
    assert_get_200_json(path = 'ready?') do |response|
      assert_equal [path], response.keys, "keys:#{last_response.body}:"
      assert false?(response[path]), "false?:#{last_response.body}:"
    end
  end

  # - - - - - - - - - - - - - - - - -

  qtest a86F16: %w[
    |GET/alive?
    |is used by external k8s probes
    |so obeys Postel's Law
    |and ignores any passed arguments
  ] do
    assert_get_200_json('alive?arg=unused') do |response|
      assert_equal ['alive?'], response.keys, "keys:#{last_response.body}:"
      assert true?(response['alive?']), "true?:#{last_response.body}:"
    end
  end

  # - - - - - - - - - - - - - - - - -

  qtest a86F17: %w[
    |GET/ready?
    |is used by external k8s probes
    |so obeys Postel's Law
    |and ignores any passed arguments
  ] do
    assert_get_200_json('ready?arg=unused') do |response|
      assert_equal ['ready?'], response.keys, "keys:#{last_response.body}:"
      assert true?(response['ready?']), "true?:#{last_response.body}:"
    end
  end

  private

  STUB_READY_FALSE = OpenStruct.new(ready?: false)

  def true?(obj)
    obj.instance_of?(TrueClass)
  end

  def false?(obj)
    obj.instance_of?(FalseClass)
  end
end
