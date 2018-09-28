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
    args = [kata_id, was_tag, now_tag]
    visible_files = singler.tags_visible_files(*args)
    http_get_hash('diff', {
      :was_files => visible_files['was_tag'],
      :now_files => visible_files['now_tag']
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

  def singler
    @externals.singler
  end

end
