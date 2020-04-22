require_relative 'app_controller_test_base'

class ReviewControllerTest < AppControllerTestBase

  def self.hex_prefix
    '1CB'
  end

  #- - - - - - - - - - - - - - - -

  test '440', %w(
  was_index!=now_index,makes 2 saver-service calls ) do
    [0,1].each do |version|
      in_kata(version:version) do |kata|
        post_run_tests # 1
        count_before = saver.log.size
        assert_review_show(kata.id, 0, 1)
        count_after = saver.log.size
        diagnostic = [version,count_before,count_after]
        assert_equal 2, (count_after-count_before), diagnostic
        assert_equal version, kata.schema.version
      end
    end
  end

  test '441', %w(
  (was_index,now_index)=(-1,-1),makes 3 saver-service calls ) do
    [0,1].each do |version|
      in_kata(version:version) do |kata|
        post_run_tests # 1
        count_before = saver.log.size
        assert_review_show(kata.id, -1, -1)
        count_after = saver.log.size
        diagnostic = [version,count_before,count_after]
        assert_equal 3, (count_after-count_before), diagnostic
        assert_equal version, kata.schema.version
      end
    end
  end

  #- - - - - - - - - - - - - - - -

  test '442',
  'was_index!=now_index, review existing version=0 session' do
    set_saver_class('SaverService')
    assert_review_show('5rTJv5', 1, 2)
  end

  test '443',
  '(was_index,now_index)=(-1,-1) review existing version=0 session' do
    set_saver_class('SaverService')
    assert_review_show('5rTJv5', -1, -1)
  end

  #- - - - - - - - - - - - - - - -

  test '444',
  'was_index!=now_index, review new version=1 session' do
    in_kata { |kata|
      post_run_tests # 1
      assert_review_show(kata.id, 0, 1)
    }
  end

  test '445',
  '(was_index,now_index)=(-1,-1), review new version=1 session' do
    in_kata { |kata|
      post_run_tests # 1
      assert_review_show(kata.id, -1, -1)
    }
  end

  #- - - - - - - - - - - - - - - -

  private

  def assert_review_show(id, was_index, now_index)
    params = { id:id, was_index:was_index, now_index:now_index }
    get '/review/show', params:params, as: :html
    assert_response :success
  end

end
