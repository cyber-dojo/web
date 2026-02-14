require_relative 'runner'

class Kata

  def initialize(externals, id)
    @externals = externals
    @id = id
  end

  attr_reader :id

  def manifest
    saver.kata_manifest(id)
  end

  def run_tests(params)
    Runner.new(@externals).run(params)
  end

  def events
    saver.kata_events(id)
  end

  def event(index)
    saver.kata_event(id, index)
  end

  private

  def saver
    @externals.saver
  end

end
