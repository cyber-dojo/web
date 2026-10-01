require 'English'

require 'json'
require 'sinatra/base'
require_relative 'http_json_hash/service'

class AppBase < Sinatra::Base
  def initialize
    super(nil)
  end

  set :port, ENV.fetch('PORT', nil)

  # - - - - - - - - - - - - - - - - - - - - - -

  def self.get_json(name)
    get "/#{name}" do
      content_type :json
      result = instance_exec do
        target.public_send(name, **args)
      end
      { name => result }.to_json
    end
  end

  # - - - - - - - - - - - - - - - - - - - - - -

  def self.probe(name)
    get "/#{name}" do
      content_type :json
      result = instance_exec do
        target.public_send(name)
      end
      { name => result }.to_json
    end
  end

  # - - - - - - - - - - - - - - - - - - - - - -

  set :show_exceptions, false

  error do
    error = $ERROR_INFO
    status(500)
    content_type('application/json')
    info = { exception: error.message }
    if error.instance_of?(::HttpJsonHash::ServiceError)
      info[:request] = {
        path: request.path
        # body:request.body.read,
      }
      info[:service] = {
        path: error.path,
        args: error.args,
        name: error.name,
        body: error.body
      }
    end
    diagnostic = JSON.pretty_generate(info)
    puts diagnostic
    body diagnostic
  end

  # - - - - - - - - - - - - - - - - - - - - - -

  def args
    payload = json_hash_parse(request.body.read)
    payload.transform_keys(&:to_sym)
  end

  private

  def json_hash_parse(body)
    json = body === '' ? {} : JSON.parse!(body)
    raise 'body is not JSON Hash' unless json.instance_of?(Hash)

    json
  rescue JSON::ParserError
    raise 'body is not JSON'
  end
end
