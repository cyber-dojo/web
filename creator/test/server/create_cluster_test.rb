require_relative 'creator_test_base'
require 'json'

class CreateClusterTest < CreatorTestBase

  def id58_setup
    @exercise_name = exercises_start_points.names.first
  end

  attr_reader :exercise_name

  # - - - - - - - - - - - - - - - - -

  qtest Cu5t6A: %w(
    |POST /create.json
    |with [type=cluster,exercise_name,language_names] params
    |where language_names holds 2+ LTFs
    |generates json route /creator/enter?id=ID
    |and a cluster with ID exists
  ) do
    language_names = languages_start_points.names.first(2)
    args = {
      exercise_name: exercise_name,
      language_names: language_names,
      type: 'cluster'
    }
    json_post mounted_path('create.json'), args
    id = json_response['id']
    assert cluster_exists?(id), "id:#{id}:"

    manifest = cluster_manifest(id)
    assert_equal id, manifest['id'], manifest
    groups = manifest['groups']
    assert_equal 2, groups.size, manifest
    assert_equal language_names, groups.values.map { |m| m['display_name'] }, manifest
    groups.each_value { |m| assert_equal exercise_name, m['exercise'], m }
  end

  # - - - - - - - - - - - - - - - - -

  qtest Cu5t6B: %w(
    |POST /create.json type=cluster
    |with an empty language_names list (0 LTFs)
    |is rejected and returns no id (a cluster needs 2-5 LTFs)
  ) do
    args = {
      exercise_name: exercise_name,
      language_names: [],
      type: 'cluster'
    }
    stdout, stderr = capture_io do
      json_post mounted_path('create.json'), args
    end
    assert status?(400), status
    assert last_response.body.include?('<div id="error-page">'), last_response.body
    assert_equal '', stderr, :stderr
    assert JSON.parse(stdout).key?('exception'), stdout
  end

  # - - - - - - - - - - - - - - - - -

  qtest Cu5t6C: %w(
    |POST /create.json type=cluster
    |with one LTF in language_names
    |is rejected and returns no id (a cluster needs 2-5 LTFs)
  ) do
    args = {
      exercise_name: exercise_name,
      language_names: languages_start_points.names.first(1),
      type: 'cluster'
    }
    stdout, stderr = capture_io do
      json_post mounted_path('create.json'), args
    end
    assert status?(400), status
    assert last_response.body.include?('<div id="error-page">'), last_response.body
    assert_equal '', stderr, :stderr
    assert JSON.parse(stdout).key?('exception'), stdout
  end

  # - - - - - - - - - - - - - - - - -

  qtest Cu5t6D: %w(
    |POST /create.json type=cluster
    |with six LTFs in language_names
    |is rejected and returns no id (a cluster needs 2-5 LTFs)
  ) do
    args = {
      exercise_name: exercise_name,
      language_names: languages_start_points.names.first(6),
      type: 'cluster'
    }
    stdout, stderr = capture_io do
      json_post mounted_path('create.json'), args
    end
    assert status?(400), status
    assert last_response.body.include?('<div id="error-page">'), last_response.body
    assert_equal '', stderr, :stderr
    assert JSON.parse(stdout).key?('exception'), stdout
  end
end
