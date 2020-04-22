require_relative 'app_controller_test_base'

class DifferControllerTest < AppControllerTestBase

  def self.hex_prefix
    '2D6'
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  test 'AF5',
  'misc json values of existing version 0 kata' do
    set_saver_class('SaverService')
    differ('5rTJv5', 'FxWwrr', 0, 1, version=0)
    assert_equal '5rTJv5', json['id']
    assert_equal 'FxWwrr', json['groupId']
    assert_equal 32, json['avatarIndex']
    assert_equal 'mouse', json['avatarName']
    assert_equal 0, json['wasIndex']
    assert_equal 1, json['nowIndex']
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  test 'AF6',
  'was_index==now_index diff of existing version=0 kata has no differences' do
    set_saver_class('SaverService')
    differ('5rTJv5', 'FxWwrr', 0, 0, version=0)
    json['diffs'].each do |diff|
      filename = diff['filename']
      assert_equal 0, diff['section_count'], filename
      assert_equal 0, diff['deleted_line_count'], filename
      assert_equal 0, diff['added_line_count'], filename
    end
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  test 'AF7',
  'was_index!=now_index diff of existing version=0 kata with a difference' do
    set_saver_class('SaverService')
    differ('5rTJv5', 'FxWwrr', 0, 1, version=0)
    json['diffs'].each do |diff|
      filename = diff['filename']
      n = (filename === 'hiker.rb') ? 1 : 0
      assert_equal n, diff['section_count'], filename
      assert_equal n, diff['deleted_line_count'], filename
      assert_equal n, diff['added_line_count'], filename
    end
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  test '215', %w(
  diff of (was,now) which is not (-1,-1) makes a single saver-service call
  ) do
    [0,1].each do |version|
      in_kata(version:version) { post_run_tests }
      count_before = saver.log.size
      differ(@id, '', 0, 1, version)
      count_after = saver.log.size
      diagnostic = [version,count_before,count_after]
      assert_equal 1, (count_after-count_before), diagnostic
      assert_equal version, kata.schema.version
    end
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  test '217', %w(
  diff of (-1,-1) makes more than one saver-service call
  ) do
    [0,1].each do |version|
      in_kata(version:version) { post_run_tests }
      count_before = saver.log.size
      differ(@id, '', -1, -1, version)
      count_after = saver.log.size
      diagnostic = [version,count_before,count_after]
      assert_equal 2, (count_after-count_before), diagnostic
      assert_equal version, kata.schema.version
    end
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  test '216', %w(
  diff of kata that is part of a group-exercise
  ) do
    [0,1].each do |version|
      @version = version
      in_group(version:version) do |group|
        @gid = group.id
        3.times do
          kata = assert_join(@gid)
          @id = kata.id
          @files = plain(kata.files)
          @index = 0
          post_run_tests
          differ(@id, @gid, 0, 1, version)
          assert_equal @id, json['id']
          assert_equal @gid, json['groupId']
        end
      end
    end
  end

  private

  def differ(id, group_id, was_index, now_index, version)
    params = {
        version:version,
             id:id,
       group_id:group_id,
      was_index:was_index,
      now_index:now_index
    }
    get '/differ/diff', params:params, as: :json
    assert_response :success
  end

end
