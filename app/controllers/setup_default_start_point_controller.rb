
class SetupDefaultStartPointController < ApplicationController

  # Regular two step setup
  # step 1. languages+test in column 1,2   (eg Java+JUnit)
  # step 2. instructions                   (eg Fizz_Buzz)

  def show_languages
    @id = id
    @title = 'create'
    languages_names = display_names_of(languages)
    index = choose_language(languages_names, id, dojo.katas)
    @start_points = ::DisplayNamesSplitter.new(languages_names, index)
    @max_seconds = dojo.runner.max_seconds
  end

  def pull_needed
    render json: { pull_needed: !dojo.runner.pulled?(language.image_name) }
  end

  def pull
    dojo.runner.pull(language.image_name)
    render json: { }
  end

  def show_instructions
    @id = id
    @title = 'create'
    @language = params[:language]
    @test = params[:test]
    @instructions_names,@instructions = read_instructions
    @initial_index = choose_instructions(@instructions_names, id, dojo.katas)
  end

  def save
    manifest = katas.create_kata_manifest(language)
    instruction_name = params['instructions']
    instruction = instructions[instruction_name]
    manifest[:exercise] = instruction.name
    manifest[:visible_files]['instructions'] = instruction.text
    kata = katas.create_kata_from_kata_manifest(manifest)
    render json: { id: kata.id }
  end

  private

  include SetupChooser

  def display_names_of(start_points)
    start_points.map(&:display_name).sort
  end

  def read_instructions
    names = []
    instructions_hash =  {}
    instructions.each do |instruction|
      names << instruction.name
      instructions_hash[instruction.name] = instruction.text
    end
    [names.sort, instructions_hash]
  end

  def language
    languages[params['major'] + '-' + params['minor']]
  end

end
