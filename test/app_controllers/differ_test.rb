require_relative 'app_controller_test_base'

class DifferControllerTest < AppControllerTestBase

  def self.hex_prefix
    '2D6238'
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  test 'AF6',
  'no lines different in any files between successive tags' do
    in_kata(:stateful) {
      as_avatar {
        filename = 'hiker.rb'
        change_file(filename, content='some_change...')
        run_tests
        run_tests
        differ(was_tag = 1, now_tag = 2)
        tags = json['tags']
        info = " " + kata.id + ":" + avatar.name
        was_light = tags[was_tag]
        assert_equal was_tag, was_light['number'], info
        now_light = tags[now_tag]
        assert_equal now_tag, now_light['number'], info
        diffs = json['diffs']
        index = diffs.find_index{|diff| diff['filename'] == filename }
        assert_equal filename, diffs[index]['filename'], info
        assert_equal 0, diffs[index]['section_count'], info
        assert_equal 0, diffs[index]['deleted_line_count'], info
        assert_equal 0, diffs[index]['added_line_count'], info
        assert_equal "<same>#{content}</same>", diffs[index]['content'], info
        assert_equal '<same><ln>1</ln></same>', diffs[index]['line_numbers'], info
      }
    }
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  test '2BF',
  'one line different in one file between successive tags' do
    in_kata(:stateful) {
      as_avatar {
        filename = 'hiker.rb'
        change_file(filename, from='fubar')
        run_tests
        change_file(filename, to='snafu')
        run_tests
        differ(was_tag = 1, now_tag = 2)
        tags = json['tags']
        info = " " + kata.id + ':' + avatar.name + ':'
        was_light = tags[was_tag]
        assert_equal was_tag, was_light['number'], info
        now_light = tags[now_tag]
        assert_equal now_tag, now_light['number'], info
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
    }
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  test 'D09',
  'tag -1 gives most recent traffic-light' do
    in_kata(:stateless) {
      as_avatar {
        run_tests # 1
        run_tests # 2
        differ(-1, -1)
        assert_equal 2, json['wasTag']
        assert_equal 2, json['nowTag']
      }
    }
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  test '490',
  'nextAvatar and prevAvatar are empty string for dojo with one avatar' do
    in_kata(:stateless) {
      as_avatar {
        run_tests # 1
        differ(0, 1)
        assert_equal '', json['prevAvatar']
        assert_equal '', json['nextAvatar']
      }
    }
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  test '76A',
  'nextAvatar and prevAvatar for dojo with two avatars' do
    in_kata(:stateless) {
      as_avatar {
        run_tests # 1
        first_avatar_name = avatar.name
        as_avatar {
          run_tests # 1
          differ(0, 1)
          assert_equal first_avatar_name, json['prevAvatar']
          assert_equal first_avatar_name, json['nextAvatar']
        }
      }
    }
  end

  private

  def differ(was_tag, now_tag)
    params = {
       'format' => 'json',
           'id' => kata.id,
       'avatar' => avatar.name,
      'was_tag' => was_tag,
      'now_tag' => now_tag
    }
    get '/differ/diff', params:params
    assert_response :success
  end

end
