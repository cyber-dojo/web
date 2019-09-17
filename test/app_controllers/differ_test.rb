require_relative 'app_controller_test_base'

class DifferControllerTest < AppControllerTestBase

  def self.hex_prefix
    '2D6'
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  test 'AF6',
  'diff where was_index==now_index results in content of all files' do
    # TODO: this is a version=0 kata
    set_saver_class('SaverService')
    differ('5rTJv5', 0, 0)
    json['diffs'].each do |diff|
      assert_equal 0, diff['section_count']
      assert_equal 0, diff['deleted_line_count']
      assert_equal 0, diff['added_line_count']
    end
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  test 'AF7',
  'diff where was_index!=now_index result in a diff' do
    set_saver_class('SaverService')
    # TODO: this is a version=0 kata    
    differ('5rTJv5', 0, 1)
  end

  private

  def differ(id, was_index, now_index)
    params = {
             id:id,
      was_files:files(id, was_index),
      now_files:files(id, now_index)
    }
    get '/differ/diff', params:params, as: :json
    assert_response :success
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  def files(id, index)
    katas[id].events[index]
             .files
             .map{ |filename,file| [filename, file['content']] }
             .to_h
  end

end

=begin
  test 'AF7',
  'dsfsdfsdfsdf' do
    in_kata {
      filename = 'hiker.rb'
      change_file(filename, content='some_change...')
      run_tests
      run_tests
      differ(was_tag = 1, now_tag = 2)
      tags = json['tags']

      info = ":#{kata.id}:#{avatar.name}:"
      # At the moment differ_controller returns lights (not tags)
      assert_equal 2, tags.size, info
      assert_equal was_tag, tags[0]['index'], info
      assert_equal now_tag, tags[1]['index'], info

      diffs = json['diffs']
      index = diffs.find_index{|diff| diff['filename'] == filename }
      assert_equal filename, diffs[index]['filename'], info
      assert_equal 0, diffs[index]['section_count'], info
      assert_equal 0, diffs[index]['deleted_line_count'], info
      assert_equal 0, diffs[index]['added_line_count'], info
      assert_equal "<same>#{content}</same>", diffs[index]['content'], info
      assert_equal '<same><ln>1</ln></same>', diffs[index]['line_numbers'], info
    }
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  test '2BF',
  'one line different in one file between successive tags' do
    in_kata {
      filename = 'hiker.rb'
      change_file(filename, from='fubar')
      run_tests
      change_file(filename, to='snafu')
      run_tests
      differ(was_tag = 1, now_tag = 2)
      tags = json['tags']

      info = " " + kata.id + ':' + avatar.name + ':'
      # At the moment differ_controller returns lights (not tags)
      assert_equal 2, tags.size, info
      assert_equal was_tag, tags[0]['index'], info
      assert_equal now_tag, tags[1]['index'], info

      diffs = json['diffs']
      index = diffs.find_index{|diff| diff['filename'] == filename }
      assert_equal filename, diffs[index]['filename'], info + "diffs[#{index}]['filename']"
      assert_equal 1, diffs[index]['section_count'], info + "diffs[#{index}]['section_count']"
      assert_equal 1, diffs[index]['deleted_line_count'], info + "diffs[#{index}]['deleted_line_count']"
      assert_equal 1, diffs[index]['added_line_count'], info + "diffs[#{index}]['added_line_count']"
      assert diffs[index]['content'].include?("<deleted>#{from}</deleted>")
      assert diffs[index]['content'].include?("<added>#{to}</added>")
      assert_equal '<deleted><ln>1</ln></deleted><added><ln>1</ln></added>',
          diffs[index]['line_numbers'], info + "diffs[0]['line_numbers']"
    }
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

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
