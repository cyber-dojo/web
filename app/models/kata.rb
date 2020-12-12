# frozen_string_literal: true
require_relative 'runner'

class Kata

  def initialize(externals, id)
    @externals = externals
    @id = id
  end

  attr_reader :id

  def manifest
    model.kata_manifest(id)
  end

  def run_tests(params)
    Runner.new(@externals).run(params)
  end

  def events
    model.kata_events(id)
  end

  def event(index)
    model.kata_event(id, index)
  end

  private

  def model
    @externals.model
  end

end
