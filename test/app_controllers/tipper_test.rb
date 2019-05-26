require_relative 'app_controller_test_base'

class TipperControllerTest < AppControllerTestBase

  def self.hex_prefix
    '25E'
  end

  # - - - - - - - - - - - - - - - - - -

  test '3D4',
  'traffic_light_tip' do
    in_kata {
      2.times {
        post_run_tests
      }
    }
    get '/tipper/traffic_light_tip', params: {
      'format'    => 'js',
      'id'        => kata.id,
      'was_index' => 0,
      'now_index' => 1
    }
    assert_response :success
  end

end
