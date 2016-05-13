
class SetupController < ApplicationController

  def show_exercises
    @id = id
    @title = 'create'
    exercises_names = read(exercises)
    index = choose_language(exercises_names, id, dojo.katas)
    @languages = ::LanguagesDisplayNamesSplitter.new(exercises_names, index)
    @initial_language_index = @languages.selected_index
  end

  def save_exercise
    language_name = params['language'] # s/languages/better-name/
    exercise_name = params['exercise']
    exercise = exercises[language_name + '-' + exercise_name]
    kata = katas.create_custom_kata(language_name, exercise)
    render json: { id: kata.id }
  end

  # - - - - - - - - - - - - - - - - - - - - - - - -

  def show_languages_and_tests
    @id = id
    @title = 'create'
    languages_names = read(languages)
    index = choose_language(languages_names, id, dojo.katas)
    @languages = ::LanguagesDisplayNamesSplitter.new(languages_names, index)
    @initial_language_index = @languages.selected_index
  end

  def show_instructions
    @id = id
    @title = 'create'
    @language = params[:language]
    @test = params[:test]
    @exercises_names,@instructions = read_instructions
    @initial_exercise_index = choose_exercise(@exercises_names, id, dojo.katas)
  end

  def save
    language_name = params['language']
        test_name = params['test'    ]
    instruction_name = params['exercise']
    language = languages[language_name + '-' + test_name]
    instruction = instructions[instruction_name]
    kata = katas.create_kata(language, instruction)
    render json: { id: kata.id }
  end

  private

  include SetupChooser
  include SetupWorker

end
