require 'json'
require 'net/http'

class RunnerService

  def initialize(_parent)
  end

  def max_seconds
    10
  end

  def pulled?(image_name)
    post('pulled', { image_name:image_name })
    status
  end

  def pull(image_name)
    post(__method__, { image_name:image_name })
  end

  # - - - - - - - - - - - - - - - - - - - - - - -

  def new_kata(kata_id, image_name)
    post(__method__, { kata_id:kata_id, image_name:image_name })
  end

  def old_kata(kata_id)
    post(__method__, { kata_id:kata_id })
  end

  # - - - - - - - - - - - - - - - - - - - - - - -

  def new_avatar(kata_id, avatar_name)
    post(__method__, { kata_id:kata_id, avatar_name:avatar_name })
  end

  def old_avatar(kata_id, avatar_name)
    post(__method__, { kata_id:kata_id, avatar_name:avatar_name })
  end

  # - - - - - - - - - - - - - - - - - - - - - - -

  def run(image_name, kata_id, avatar_name, deleted_filenames, changed_files, max_seconds)
    post(__method__, {
                 image_name:image_name,
                    kata_id:kata_id,
                avatar_name:avatar_name,
          deleted_filenames:deleted_filenames,
              changed_files:changed_files,
                max_seconds:max_seconds
    })
    [stdout,stderr,status]
  end

  private

  def json; @json; end
  def stdout; json['stdout']; end
  def stderr; json['stderr']; end
  def status; json['status']; end

  def post(method, args)
    uri = URI.parse('http://runner:4557/' + method.to_s)
    http = Net::HTTP.new(uri.host, uri.port)
    request = Net::HTTP::Post.new(uri.request_uri)
    request.content_type = 'application/json'
    request.body = args.to_json
    response = http.request(request)
    @json = JSON.parse(response.body)
  end

end


