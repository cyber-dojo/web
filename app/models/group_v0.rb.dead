# frozen_string_literal: true

class Group_v0

  def initialize(externals)
    @externals = externals
  end

  def exists?(id)
    saver.group_exists?(id)
  end

  def create(manifest)
    saver.group_create(manifest)
  end

  def manifest(id)
    saver.group_manifest(id)
  end

  def join(id, indexes)
    saver.group_join(id, indexes)
  end

  def joined(id)
    saver.group_joined(id)
  end

  def events(id)
    saver.group_events(id)
  end

  private

  def saver
    @externals.saver
  end

end
