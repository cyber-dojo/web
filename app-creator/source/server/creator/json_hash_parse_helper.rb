module CreatorApp
  module JsonHashParseHelper
    def json_hash_parse(body)
      json = body == '' ? {} : JSON.parse!(body)
      raise 'body is not JSON Hash' unless json.instance_of?(Hash)

      json
    rescue JSON::ParserError
      raise 'body is not JSON'
    end
  end
end
