# frozen_string_literal: true

require_relative 'id_pather'
require_relative '../services/saver_asserter'
require_relative '../../lib/oj_adapter'

module Version

  def group_version
    version(:group_id_path)
  end

  def kata_version
    version(:kata_id_path)
  end

  private

  def version(pather)
    # TODO: use @params[:version]
    path = method(pather).call(id, 'manifest.json')
    manifest_src = saver.read(path)
    saver_assert(manifest_src.is_a?(String))
    json_parse(manifest_src)['version'] || 0
  end

  include IdPather
  include OjAdapter
  include SaverAsserter

end
