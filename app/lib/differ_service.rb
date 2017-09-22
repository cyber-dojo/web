require_relative 'http_helper'

class DifferService

  def initialize(parent)
    @parent = parent
  end

  attr_reader :parent

  def diff(kata_id, avatar_name, was_tag, now_tag)
    args = [kata_id, avatar_name, was_tag, now_tag]
    visible_files = storer.tags_visible_files(*args)
    http_get_hash('diff', {
      :was_files => visible_files['was_tag'],
      :now_files => visible_files['now_tag']
    })
  end

  private

  include HttpHelper

  def hostname
    'differ'
  end

  def port
    4567
  end

  def storer
    nearest_ancestors(:storer)
  end

end
