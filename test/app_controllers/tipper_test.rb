require_relative 'app_controller_test_base'

class TipperControllerTest < AppControllerTestBase

  def self.hex_prefix
    '25E'
  end

  # - - - - - - - - - - - - - - - - - -

  test '3D4',
  'V1: traffic_light_tip uses 7 saver-service calls' do
    in_kata { post_run_tests }
    count_before = saver.log.size
    get '/tipper/traffic_light_tip', params: {
      'format'    => 'js',
      'id'        => kata.id,
      'was_index' => 0,
      'now_index' => 1
    }
    assert_response :success
    count_after = saver.log.size
    #puts [count_before,count_after] # [14,21]
    assert_equal 7, (count_after-count_before)
    assert_equal 1, kata.schema.version
  end

  # - - - - - - - - - - - - - - - - - -

  test '3D5',
  'V1: traffic_light_tip2 uses only one saver-service call' do
    in_kata { post_run_tests }
    count_before = saver.log.size
    get '/tipper/traffic_light_tip2', params: {
         format: :js,
        version: 1,
             id: kata.id,
      was_index: 0,
      now_index: 1
    }
    assert_response :success
    count_after = saver.log.size
    #puts [count_before,count_after] # [14,15]
    assert_equal 1, (count_after-count_before)
    assert_equal 1, kata.schema.version
  end

  # - - - - - - - - - - - - - - - - - -

  test '3D6',
  'V0: traffic_light_tip2 uses only one saver-service call' do
    manifest = starter_manifest('Java, JUnit')
    version = manifest['version'] = 0
    kata = katas.new_kata(manifest)
    @files = plain(kata.files)
    @index = 0
    @id = kata.id
    post_run_tests
    count_before = saver.log.size
    get '/tipper/traffic_light_tip2', params: {
         format: :js,
        version: 0,
             id: kata.id,
      was_index: 0,
      now_index: 1
    }
    assert_response :success
    count_after = saver.log.size
    #puts [count_before,count_after] # [15,16]
    assert_equal 1, (count_after-count_before)
    assert_equal 0, kata.schema.version
  end

end
