# frozen_string_literal: true

require_relative 'group'
require_relative 'schema'
require_relative 'version'

class Groups

  def initialize(externals, params)
    @externals = externals
    @params = params
  end

  def [](id)
    Group.new(@externals, @params.merge({id:id}))
  end

  def new_group(manifest)
    version = manifest_version(manifest)
    id = Schema.new(@externals, version).group.create(manifest)
    Group.new(@externals, @params.merge({id:id,version:version}))
  end

  private

  include Version

end
