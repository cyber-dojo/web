
class SetupCustomStartPointController < ApplicationController

  # Custom exercise one-step setup

  def show_exercises
    @id = id
    @title = 'create'
    exercises_names = display_names_of(exercises)
    index = choose_language(exercises_names, id, dojo.katas)
    @display_names = ::DisplayNamesSplitter.new(exercises_names, index)
    @initial_index = @display_names.initial_index
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

  def display_names_of(start_points)
    start_points.map(&:display_name).sort
  end

end
