# frozen_string_literal: true

class Kata_v0

  def initialize(externals)
    @externals = externals
  end

  def exists?(id)
    saver.kata_exists?(id)
  end

  def create(manifest)
    saver.kata_create(manifest)
  end

  def manifest(id)
    saver.kata_manifest(id)
  end

  def ran_tests(id, index, files, now, duration, stdout, stderr, status, colour)
    saver.kata_ran_tests(id, index, files, now, duration, stdout, stderr, status, colour)
  end

  def events(id)
    saver.kata_events(id)
  end

  def event(id, index)
    saver.kata_event(id, index)
  end

  private

  def saver
    @externals.saver
  end

end
