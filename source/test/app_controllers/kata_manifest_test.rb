require_relative 'app_controller_test_base'

class KataManifestTest < AppControllerTestBase

  test 'C7B3F2a', %w(
  | manifest returns the kata manifest
  ) do
    in_kata do
      get '/kata/manifest', { id: @id }
      assert last_response.ok?
      assert_equal @manifest['image_name'], json['kata_manifest']['image_name']
    end
  end

end
