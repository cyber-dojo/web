require_relative 'app_controller_test_base'

class KataDownloadTest < AppControllerTestBase

  test 'E8D2A1a', %w(
  | download returns a filename and base64 contents for a v2 kata
  ) do
    in_kata(version: 2) do
      get '/kata/download', { id: @id }
      assert last_response.ok?
      assert_equal 2, json['kata_download'].size
    end
  end

end
