require_relative 'app_controller_test_base'

class TipperControllerTest < AppControllerTestBase

  def self.hex_prefix
    '25E'
  end

  # - - - - - - - - - - - - - - - - - -

  test '3D5',
  'new traffic_light_tip uses 1 saver-service call' do
    [0,1].each do |version|
      in_kata(version:version) do |kata|
        post_run_tests
        count_before = saver.log.size
        get '/tipper/traffic_light_tip', params:tip_params(version,kata)
        assert_response :success
        count_after = saver.log.size
        diagnostic = [version,count_before,count_after]
        assert_equal 1, (count_after-count_before), diagnostic
      end
    end
  end

  # TODO: add 3D5 but for kata in a group

  # - - - - - - - - - - - - - - - - - -

  def tip_params(version, kata)
    {
         format: :js,
        version: version,
             id: kata.id,
      was_index: 0,
      now_index: 1
    }
  end

end
