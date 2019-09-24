# frozen_string_literal: true

require_relative 'kata'
require_relative 'schema'
require_relative 'version'

class Katas

  def initialize(externals, params)
    @externals = externals
    @params = params
  end

  def [](id)
    Kata.new(@externals, @params.merge({id:id}))
  end

  def new_kata(manifest)
    version = manifest_version(manifest)
    id = Schema.new(@externals, version).kata.create(manifest)
    Kata.new(@externals, @params.merge({id:id,version:version}))
  end

  private

  include Version

end
