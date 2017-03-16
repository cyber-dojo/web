require_relative 'http_service'
require_relative '../../lib/nearest_ancestors'

class DifferService

  def initialize(parent)
    @parent = parent
  end

  attr_reader :parent

  def diff(kata_id, avatar_name, was_tag, now_tag)
    # See https://github.com/cyber-dojo/commander
    # and its docker-compose.yml
    args = [kata_id, avatar_name, was_tag, now_tag]
    visible_files = storer.tags_visible_files(*args)
    args = {
      :was_files => visible_files['was_tag'],
      :now_files => visible_files['now_tag']
    }
    http('diff', args) { |uri| Net::HTTP::Get.new(uri) }
  end

  private

  include HttpService
  def hostname; 'differ'; end
  def port; 4567; end

  include NearestAncestors
  def storer; nearest_ancestors(:storer); end

end
