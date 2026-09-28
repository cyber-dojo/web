require 'json'

module CreatorApp
  class Creator
    def initialize(externals)
      @externals = externals
    end

    def cluster_create(language_names:, exercise_name:)
      manifests = language_names.map do |language_name|
        manifest(language_name, exercise_name)
      end
      create_cluster(manifests)
    end

    def group_create(language_name:, exercise_name:)
      create_group(manifest(language_name, exercise_name))
    end

    def kata_create(language_name:, exercise_name:)
      create_kata(manifest(language_name, exercise_name))
    end

    # - - - - - - - - - - - - - - - - -

    def group_create_custom(display_name:)
      create_group(custom_manifest(display_name))
    end

    def kata_create_custom(display_name:)
      create_kata(custom_manifest(display_name))
    end

    private

    def create_cluster(manifests)
      id = saver.cluster_create(manifests)
      manifests.each do |manifest|
        pull_image_onto_nodes(id, manifest['image_name'])
      end
      id
    end

    def create_group(manifest)
      id = saver.group_create(manifest)
      pull_image_onto_nodes(id, manifest['image_name'])
      id
    end

    def create_kata(manifest)
      id = saver.kata_create(manifest)
      pull_image_onto_nodes(id, manifest['image_name'])
      id
    end

    def custom_manifest(name)
      custom_start_points.manifest(name)
    end

    def manifest(language_name, exercise_name)
      result = languages_start_points.manifest(language_name)
      unless exercise_name == ''
        exercise = exercises_start_points.manifest(exercise_name)
        result['visible_files'].merge!(exercise['visible_files'])
        result['exercise'] = exercise['display_name']
      end
      result
    end

    def pull_image_onto_nodes(id, image_name)
      # you cannot make http requests to individual runners.
      # So instead, send the request many times (it is asynchronous),
      # and rely on one request reaching each node. If a node is missed
      # it simply means the image will get pulled onto the node on the
      # first run_cyber_dojo_sh() call, and at the browser, the [test]
      # will result in an hour-glass icon.
      16.times { runner.pull_image(id, image_name) }
    end

    def custom_start_points
      @externals.custom_start_points
    end

    def exercises_start_points
      @externals.exercises_start_points
    end

    def languages_start_points
      @externals.languages_start_points
    end

    def runner
      @externals.runner
    end

    def saver
      @externals.saver
    end
  end
end
