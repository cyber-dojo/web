require_relative 'http_helper'

class DifferService

  def initialize(externals)
    @externals = externals
    @http = HttpHelper.new(externals, self, 'differ', 4567)
  end

  # - - - - - - - - - - - - -

  def sha
    @http.get(__method__)
  end

  # - - - - - - - - - - - - -

  def diff(kata_id, was_tag, now_tag)
    @http.get_hash('diff', {
      :was_files => files(kata_id, was_tag),
      :now_files => files(kata_id, now_tag)
    })
  end

  private

  def files(kata_id, tag)
    event = @externals.saver.kata_event(kata_id, tag)
    all = event['files']
    all['stdout'] = event['stdout']
    all['stderr'] = event['stderr']
    all['status'] = event['status'].to_s
    all
  end

end
