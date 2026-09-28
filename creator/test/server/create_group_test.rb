require_relative 'creator_test_base'
require 'json'

class CreateGroupTest < CreatorTestBase

  def id58_setup
    @display_name = custom_start_points.names.sample
    @language_name = languages_start_points.names.sample
    @exercise_name = exercises_start_points.names.sample
  end

  attr_reader :exercise_name, :display_name, :language_name

  # - - - - - - - - - - - - - - - - -

  qtest p42w9A: %w(
    |POST /create.json
    |with [type=group,exercise_name,language_name] URL params
    |generates json route /creator/enter?id=ID
    |and a group-exercise with ID exists
  ) do
    args = {
      exercise_name: exercise_name,
      language_name: language_name,
      type: 'group'
    }
    json_post mounted_path('create.json'), args
    id = json_response['id']
    assert group_exists?(id), "id:#{id}:" # eg "xCSKgZ"
    manifest = group_manifest(id)
    assert_equal language_name, manifest['display_name'], manifest
    assert_equal exercise_name, manifest['exercise'], manifest
  end

  # - - - - - - - - - - - - - - - - -

  qtest p42w9B: %w(
    |POST /create.json
    |with [type=group,language_name] URL params
    |and empty exercise_name (skipped)
    |generates json route /creator/enter?id=ID
    |and a group-exercise with ID exists
  ) do
    args = {
      exercise_name: '',
      language_name: language_name,
      type: 'group'
    }
    json_post mounted_path('create.json'), args
    id = json_response['id']
    assert group_exists?(id), "id:#{id}:" # eg "xCSKgZ"
    manifest = group_manifest(id)
    assert_equal language_name, manifest['display_name'], manifest
    assert manifest.key?('exercise')
    assert_equal '', manifest['exercise'], :polyfilled
  end

  # - - - - - - - - - - - - - - - - -

  qtest p42w9C: %w(
    |POST /create.json
    |with [type=group,display_name] URL params
    |generates json route /creator/enter?id=ID
    |and a group-exercise with ID exists
  ) do
    args = {
      display_name: display_name,
      type: 'group'
    }
    json_post mounted_path('create.json'), args
    id = json_response['id']
    assert group_exists?(id), "id:#{id}:" # eg "xCSKgZ"
    manifest = group_manifest(id)
    assert_equal display_name, manifest['display_name'], manifest
    assert manifest.key?('exercise')
    assert_equal '', manifest['exercise'], :polyfilled
  end
end
