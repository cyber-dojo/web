require_relative 'creator_test_base'
require 'json'

class CreateKataTest < CreatorTestBase

  def id58_setup
    @display_name = custom_start_points.names.sample
    @language_name = languages_start_points.names.sample
    @exercise_name = exercises_start_points.names.sample
  end

  attr_reader :display_name, :language_name, :exercise_name

  # - - - - - - - - - - - - - - - - -

  qtest p43w9A: %w(
    |POST /create.json
    |with [type=single,language_name,exercise_name] URL params
    |generates json route /creator/enter?id=ID
    |and a kata-exercise with ID exists
  ) do
    json_post_create({
                       language_name: language_name,
                       exercise_name: exercise_name
                     }) do |manifest|
      assert_equal language_name, manifest['display_name'], manifest
      assert_equal exercise_name, manifest['exercise'], manifest
    end
  end

  # - - - - - - - - - - - - - - - - -

  qtest p43w9B: %w(
    |POST /create.json
    |with [type=single,language_name] URL params
    |and empty exercise_name (skipped)
    |generates json route /creator/enter?id=ID
    |and a kata-exercise with ID exists
  ) do
    json_post_create({
                       exercise_name: '',
                       language_name: language_name
                     }) do |manifest|
      assert_equal language_name, manifest['display_name'], manifest
      assert manifest.key?('exercise')
      assert_equal '', manifest['exercise'], :polyfilled
    end
  end

  # - - - - - - - - - - - - - - - - -

  qtest p43w9C: %w(
    |POST /create.json
    |with [type=single,display_name] URL params
    |generates json route /creator/enter?id=ID
    |and a kata-exercise with ID exists
  ) do
    json_post_create({
                       display_name: display_name
                     }) do |manifest|
      assert_equal display_name, manifest['display_name'], manifest
      assert manifest.key?('exercise')
      assert_equal '', manifest['exercise'], :polyfilled
    end
  end

  private

  def json_post_create(args)
    args[:type] = 'single'
    json_post mounted_path('create.json'), args
    id = json_response['id']
    assert kata_exists?(id), "id:#{id}:" # eg "xCSKgZ"
    yield kata_manifest(id)
  end
end
