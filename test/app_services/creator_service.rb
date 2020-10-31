# frozen_string_literal: true
def require_source(path)
  require_relative "../../app/services/#{path}"
end

require_source 'http_json/requester'
require_source 'http_json/responder'

class CreatorService

  class Error < RuntimeError
    def initialize(message)
      super
    end
  end

  def initialize(externals)
    name = 'creator'
    port = ENV['CYBER_DOJO_CREATOR_PORT'].to_i
    requester = HttpJson::Requester.new(externals.http, name, port)
    @http = HttpJson::Responder.new(requester, Error, {keyed:false})
  end

  def ready?
    @http.get(__method__, {})
  end

  def group_create(language_name, exercise_name)
    json = @http.post('create.json', {
      type:'group',
      language_name:language_name,
      exercise_name:exercise_name
    })
    json['id']
  end

  def kata_create(language_name, exercise_name)
    json = @http.post('create.json', {
      type:'kata',
      language_name:language_name,
      exercise_name:exercise_name
    })
    json['id']
  end

  # - - - - - - - - - - - - - - - -
  # deprecated

  def group_create_custom(display_name)
    json = @http.post('create.json', {
      type:'group',
      display_name:display_name
    })
    json['id']
  end

  def kata_create_custom(display_name)
    json = @http.post('create.json', {
      type:'kata',
      display_name:display_name
    })
    json['id']
  end

  # - - - - - - - - - - - - - - - -

  def create(id, old_files, new_files)
    @http.post(__method__, {
      id:id,
      old_files:old_files,
      new_files:new_files
    })
  end

end
