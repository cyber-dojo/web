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

  private

  def differ(id, was_index, now_index)
    params = {
             id:id,
      was_index:was_index,
      now_index:now_index
    }

    get '/differ/diff', params:params, as: :json
    assert_response :success
  end

end

=begin
  test 'D09',
  'tag -1 gives most recent traffic-light' do
    in_kata {
      run_tests # 1
      run_tests # 2
      differ(-1, -1)
      assert_equal 2, json['wasTag']
      assert_equal 2, json['nowTag']
    }
  end
=end
