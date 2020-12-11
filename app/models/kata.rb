# frozen_string_literal: true
require_relative 'runner'

class Kata

  def initialize(externals, params)
    @externals = externals
    @params = params
  end

  def id
    @params[:id]
  end

  def exists?
    model.kata_exists?(id)
  rescue
    false
  end

  def manifest
    @manifest ||= model.kata_manifest(id)
  end

  # - - - - - - - - - - - - - - - - -

  def run_tests(params = @params)
    Runner.new(@externals).run(params)
  end

  def events
    model.kata_events(id)
  end

  def event(index)
    model.kata_event(id, index)
  end

  # - - - - - - - - - - - - - - - - -

  def theme
    model.kata_option_get(id, 'theme')
  end

  def theme=(value)
    model.kata_option_set(id, 'theme', value)
  end

  # - - - - - - - - - - - - - - - - -

  def colour
    model.kata_option_get(id, 'colour')
  end

  def colour=(value)
    model.kata_option_set(id, 'colour', value)
  end

  # - - - - - - - - - - - - - - - - -

  def predict
    model.kata_option_get(id, 'predict')
  end

  def predict=(value)
    model.kata_option_set(id, 'predict', value)
  end

  private

  def model
    @externals.model
  end

end
