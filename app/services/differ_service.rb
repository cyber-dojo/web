require_relative 'http_helper'

class DifferService

  def initialize(externals)
    @externals = externals
    @http = HttpHelper.new(externals, self, 'differ', 4567)
  end

  # - - - - - - - - - - - - -

  def sha
    http.get(__method__)
  end

  # - - - - - - - - - - - - -

  def diff(kata_id, was_tag, now_tag)
    saver = externals.saver
    http.get_hash('diff', {
      :was_files => saver.kata_event(kata_id, was_tag)['files'],
      :now_files => saver.kata_event(kata_id, now_tag)['files']
    })
  end

  private

  attr_reader :externals, :http

end
