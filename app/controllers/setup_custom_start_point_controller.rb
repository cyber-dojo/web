
class SetupCustomStartPointController < ApplicationController

  # Custom exercise one-step setup

  def show_exercises
    @id = id
    @title = 'create'
    exercises_names = read(exercises)
    index = choose_language(exercises_names, id, dojo.katas)
    @languages = ::DisplayNamesSplitter.new(exercises_names, index)
    @initial_language_index = @languages.selected_index
  end

  def pull_needed
    language_name = params['language']
        test_name = params['test'    ]
    exercise = exercises[language_name + '-' + test_name]
    image_name = exercise.image_name
    answer = !dojo.runner.pulled?(image_name)
    render json: { pull_needed: answer }
  end

  def pull
    language_name = params['language']
        test_name = params['test'    ]
    exercise = exercises[language_name + '-' + test_name]
    image_name = exercise.image_name
    dojo.runner.pull(image_name)
    render json: { }
  end

  def save
    language_name = params['language']
        test_name = params['test']
    exercise = exercises[language_name + '-' + test_name]
    manifest = katas.create_kata_manifest(exercise)
    kata = katas.create_kata_from_kata_manifest(manifest)
    render json: { id: kata.id }
  end

  private

  include SetupChooser

  def read(manifests)
    manifests.map(&:display_name).sort
  end

end
