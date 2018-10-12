require_relative 'http_helper'

class DifferService

  def initialize(externals)
    @externals = externals
  end

  # - - - - - - - - - - - - -

  def sha
    http_get(__method__)
  end

  # - - - - - - - - - - - - -

  def diff(kata_id, was_tag, now_tag)
    http_get_hash('diff', {
      :was_files => saver.kata_tag(kata_id, was_tag)['files'],
      :now_files => saver.kata_tag(kata_id, now_tag)['files']
    })

  end

  private # = = = = = = = = =

  include HttpHelper

  def hostname
    'differ'
  end

  def port
    4567
  end

  def saver
    @externals.saver
  end

end
