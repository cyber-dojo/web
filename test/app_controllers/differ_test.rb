require_relative 'app_controller_test_base'

class DifferControllerTest < AppControllerTestBase

  def self.hex_prefix
    '2D6'
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  test 'AF6',
  'diff with no differences' do
    set_saver_class('SaverService')
    differ('5rTJv5', 0, 0)
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
    differ('5rTJv5', 0, 1)
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
    differ('5rTJv5', -1, -1)
    assert_equal 3, json['wasIndex']
    assert_equal 3, json['nowIndex']
    assert_equal 32, json['avatarIndex']
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  test 'AF9', %w(
  index -1 gives most recent traffic-light
  when saver-outage means indexes are not sequential
  ) do

  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  test '115', %w( checking saver call efficiency ) do
    manifest = starter_manifest('Python, unittest')
    version = manifest['version'] = 1
    kata = katas.new_kata(manifest)
    @id = kata.id
    @files = plain(kata.files)
    @index = 0
    post_run_tests
    count_before = saver.log.size #13
    differ(@id, 0, 1, version)
    count_after = saver.log.size # 19
    puts [count_before,count_after]
    assert_equal 6, (count_after-count_before)
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  private

  def differ(id, was_index, now_index, version = 0)
    params = {
        version:version,
             id:id,
      was_index:was_index,
      now_index:now_index
    }

    get '/differ/diff', params:params, as: :json
    assert_response :success
  end

end
