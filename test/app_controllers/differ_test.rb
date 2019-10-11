require_relative 'app_controller_test_base'

class DifferControllerTest < AppControllerTestBase

  def self.hex_prefix
    '2D6'
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  test 'AF5',
  'misc json values' do
    set_saver_class('SaverService')
    differ('5rTJv5', 0, 1, version=0)
    assert_equal '5rTJv5', json['id']
    assert_equal 32, json['avatarIndex']
    assert_equal 'mouse', json['avatarName']
    assert_equal 0, json['wasIndex']
    assert_equal 1, json['nowIndex']
  end

  test 'BF5',
  'misc json values' do
    set_saver_class('SaverService')
    differ2('5rTJv5', 0, 1, version=0)
    assert_equal '5rTJv5', json['id']
    assert_equal 32, json['avatarIndex']
    assert_equal 'mouse', json['avatarName']
    assert_equal 0, json['wasIndex']
    assert_equal 1, json['nowIndex']
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  test 'AF6',
  'diff with no differences' do
    set_saver_class('SaverService')
    differ('5rTJv5', 0, 0, version=0)
    json['diffs'].each do |diff|
      filename = diff['filename']
      assert_equal 0, diff['section_count'], filename
      assert_equal 0, diff['deleted_line_count'], filename
      assert_equal 0, diff['added_line_count'], filename
    end
  end

  test 'BF6',
  'diff with no differences' do
    set_saver_class('SaverService')
    differ2('5rTJv5', 0, 0, version=0)
    json['diffs'].each do |diff|
      filename = diff['filename']
      assert_equal 0, diff['section_count'], filename
      assert_equal 0, diff['deleted_line_count'], filename
      assert_equal 0, diff['added_line_count'], filename
    end
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  test 'AF7',
  'diff with one line difference in only one file' do
    set_saver_class('SaverService')
    differ('5rTJv5', 0, 1, version=0)
    json['diffs'].each do |diff|
      filename = diff['filename']
      n = (filename === 'hiker.rb') ? 1 : 0
      assert_equal n, diff['section_count'], filename
      assert_equal n, diff['deleted_line_count'], filename
      assert_equal n, diff['added_line_count'], filename
    end
  end

  test 'BF7',
  'diff with one line difference in only one file' do
    set_saver_class('SaverService')
    differ2('5rTJv5', 0, 1, version=0)
    json['diffs'].each do |diff|
      filename = diff['filename']
      n = (filename === 'hiker.rb') ? 1 : 0
      assert_equal n, diff['section_count'], filename
      assert_equal n, diff['deleted_line_count'], filename
      assert_equal n, diff['added_line_count'], filename
    end
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  test 'AF8', %w(
  index -1 gives most recent traffic-light
  when no-saver-outages means indexes are sequential
  ) do
    set_saver_class('SaverService')
    differ('5rTJv5', -1, -1, version=0)
    assert_equal 3, json['wasIndex']
    assert_equal 3, json['nowIndex']
    assert_equal 32, json['avatarIndex']
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  test 'AF9', %w(
  index -1 gives most recent traffic-light
  when saver-outage means indexes are not sequential
  ) do
    in_kata { post_run_tests }
    # saver-outage 1,2,3
    @index = 3
    post_run_tests
    differ(@id, -1, -1, version=1)
    assert_equal 4, json['wasIndex']
    assert_equal 4, json['nowIndex']
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  test '115', %w(
  saver-service call efficiency
  ) do
    [0,1].each do |version|
      in_kata(version:version) { post_run_tests }
      count_before = saver.log.size
      differ(@id, 0, 1, version)
      count_after = saver.log.size
      diagnostic = [version,count_before,count_after]
      assert_equal 6, (count_after-count_before), diagnostic
      assert_equal version, kata.schema.version
    end
  end

  test '215', %w(
  saver-service call efficiency
  ) do
    [0,1].each do |version|
      in_kata(version:version) { post_run_tests }
      count_before = saver.log.size
      differ2(@id, 0, 1, version)
      count_after = saver.log.size
      diagnostic = [version,count_before,count_after]
      assert_equal 1, (count_after-count_before), diagnostic
      assert_equal version, kata.schema.version
    end
  end

  private

  def differ(id, was_index, now_index, version)
    params = {
        version:version,
             id:id,
      was_index:was_index,
      now_index:now_index
    }

    get '/differ/diff', params:params, as: :json
    assert_response :success
  end

  #- - - - - - - - - - - - - - - -

  def differ2(id, was_index, now_index, version)
    params = {
        version:version,
             id:id,
      was_index:was_index,
      now_index:now_index
    }

    get '/differ/diff2', params:params, as: :json
    assert_response :success
  end

end
