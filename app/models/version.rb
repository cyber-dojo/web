# frozen_string_literal: true

module Version

  def kata_version
    version(:kata)
  end

  def manifest_version(manifest)
    # if manifest['version'].nil?
    # then nil.to_i ==> 0
    # which is what we want
    manifest['version'].to_i
  end

  private

  def version(who)
    @version ||= begin
      if @params.has_key?(:version)
        @params[:version].to_i
      elsif who === :kata
        manifest_version(model.kata_manifest(id))
      end
    end
  end

end
