# frozen_string_literal: true

require_relative 'group'
require_relative 'schema'

class Groups

  def initialize(externals)
    @externals = externals
  end

  def [](id)
    Group.new(externals, id)
  end

  def new_group(manifest)
    version = manifest['version'] || 0
    id = Schema.new(externals, version).group.create(manifest)
    self[id]
  end

  private

  attr_reader :externals

end
