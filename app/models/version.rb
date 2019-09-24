# frozen_string_literal: true

require_relative 'id_pather'
require_relative 'saver_asserter'
require_relative '../../lib/oj_adapter'

module Version

  def group_version
    version(:group_id_path)
  end

  def kata_version
    version(:kata_id_path)
  end

  def manifest_version(manifest)
    manifest['version'].to_i || 0
  end

  private

  def version(pather)
    @version ||= @params[:version].to_i
    @version ||= begin
      path = method(pather).call(id, 'manifest.json')
      manifest_src = saver_assert(['read',path])
      manifest_version(json_parse(manifest_src))
    end
  end

  include IdPather
  include OjAdapter
  include SaverAsserter

end
