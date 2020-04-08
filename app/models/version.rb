# frozen_string_literal: true

require_relative 'id_pather'
require_relative '../../lib/oj_adapter'

module Version

  def group_version
    version(:group_id_path)
  end

  def kata_version
    version(:kata_id_path)
  end

  def manifest_version(manifest)
    # if manifest['version'].nil?
    # then nil.to_i ==> 0
    # which is what we want
    manifest['version'].to_i
  end

  private

  def version(pather)
    @version ||= begin
      if @params.has_key?(:version)
        @params[:version].to_i
      else
        path = method(pather).call(id, 'manifest.json')
        manifest_src = saver.assert(saver.file_read_command(path))
        manifest_version(json_parse(manifest_src))
      end
    end
  end

  include IdPather
  include OjAdapter

end
