require_relative 'http_helper'

class StorerService

  def initialize(parent)
    @parent = parent
    @hostname = ENV['STORER_HOSTNAME'] || 'storer'
    @port = ENV['STORER_PORT'] || 4577
  end

  attr_reader :parent

  # - - - - - - - - - - - -

  def create_kata(        manifest)
    http_post(__method__, manifest)
  end

  def kata_exists?(      kata_id)
    http_get(__method__, kata_id)
  end

  def kata_manifest(     kata_id)
    http_get(__method__, kata_id)
  end

  def kata_increments(   kata_id)
    http_get(__method__, kata_id)
  end

  # - - - - - - - - - - - -

  def completed(         kata_id)
    http_get(__method__, kata_id)
  end

  def completions(       kata_id)
    http_get(__method__, kata_id)
  end

  # - - - - - - - - - - - -

  def avatar_exists?(    kata_id, avatar_name)
    http_get(__method__, kata_id, avatar_name)
  end

  def start_avatar(       kata_id, avatar_names)
    http_post(__method__, kata_id, avatar_names)
  end

  def started_avatars(   kata_id)
    http_get(__method__, kata_id)
  end

  # - - - - - - - - - - - -

  def avatar_ran_tests(   kata_id, avatar_name, files, now, output, colour)
    http_post(__method__, kata_id, avatar_name, files, now, output, colour)
  end

  def avatar_increments( kata_id, avatar_name)
    http_get(__method__, kata_id, avatar_name)
  end

  def avatar_visible_files(kata_id, avatar_name)
    http_get(__method__,   kata_id, avatar_name)
  end

  # - - - - - - - - - - - -

  def tag_visible_files( kata_id, avatar_name, tag)
    http_get(__method__, kata_id, avatar_name, tag)
  end

  def tags_visible_files(kata_id, avatar_name, was_tag, now_tag)
    http_get(__method__, kata_id, avatar_name, was_tag, now_tag)
  end

  private

  include HttpHelper
  attr_reader :hostname, :port

end
