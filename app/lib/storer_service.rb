require 'json'
require 'net/http'
require_relative 'http_service'

class StorerService

  def initialize(_parent)
  end

  # - - - - - - - - - - - -

  def path
    get(__method__)
  end

  # - - - - - - - - - - - -

  def create_kata(manifest)
    post(__method__, manifest)
  end

  def kata_manifest(kata_id)
    get(__method__, kata_id)
  end

  # - - - - - - - - - - - -

  def completed(kata_id)
    get(__method__, kata_id)
  end

  def completions(kata_id)
    get(__method__, kata_id)
  end

  # - - - - - - - - - - - -

  def start_avatar(kata_id, avatar_names)
    post(__method__, kata_id, avatar_names)
  end

  def started_avatars(kata_id)
    get(__method__, kata_id)
  end

  # - - - - - - - - - - - -

  def avatar_ran_tests(kata_id, avatar_name, files, now, output, colour)
    post(__method__, kata_id, avatar_name, files, now, output, colour)
  end

  # - - - - - - - - - - - -

  def avatar_increments(kata_id, avatar_name)
    get(__method__, kata_id, avatar_name)
  end

  def avatar_visible_files(kata_id, avatar_name)
    get(__method__, kata_id, avatar_name)
  end

  # - - - - - - - - - - - -

  def tag_visible_files(kata_id, avatar_name, tag)
    get(__method__, kata_id, avatar_name, tag)
  end

  def tags_visible_files(kata_id, avatar_name, was_tag, now_tag)
    get(__method__, kata_id, avatar_name, was_tag, now_tag)
  end

  private

  include HttpService
  def hostname; 'storer'; end
  def port; 4577; end

end
