require_relative 'app_controller_test_base'

class DownloadControllerTest < AppControllerTestBase

  def prepare
    set_storer_class('StorerService')
    @id = create_kata
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  # download
  #- - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  test 'C440EF',
  'download with empty id raises' do
    @id = ''
    error = assert_raises(StandardError) {
      download
    }
    assert error.message.end_with?'invalid kata_id', error.message
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  test 'C44849',
  'download with bad id raises' do
    @id = 'XX'
    error = assert_raises(StandardError) {
      download
    }
    assert error.message.end_with?'invalid kata_id', error.message
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  test 'C44561',
  'download of empty dojo with no avatars',
  'untars to same as original folder' do
    prepare
    download
    assert_downloaded
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  test 'C441B1',
  'download of dojo with one avatar and one traffic-light',
  'untars to same as original folder' do
    prepare
    start
    kata_edit
    change_file('hiker.rb', 'def...')
    run_tests
    download
    assert_downloaded
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  test 'C44E9B',
  'download of dojo with five animals and five traffic-lights',
  'untars to same as original folder' do
    prepare
    5.times do
      start
      kata_edit
      change_file('hiker.rb', 'def...')
      run_tests
      change_file('test_hiker.rb', 'def...')
      run_tests
    end
    download
    assert_downloaded
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  # download_tag
  #- - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  test 'C446F7',
  'download_tag with empty kata_id raises' do
    @id = ''
    @avatar = 'salmon'
    @tag = 0
    error = assert_raises(StandardError) {
      download_tag
    }
    assert error.message.end_with?'invalid kata_id', error.message
  end

  private

  def download
    get 'download', 'id' => @id
  end

  def assert_downloaded
    assert_response :success
    tmp_zipper = ENV['CYBER_DOJO_ZIPPER_ROOT']
    tgz_filename = "#{tmp_zipper}/#{@id}.tgz"
    assert File.exists? tgz_filename
  end

  def download_tag
    get 'download_tag', 'id' => @id, 'avatar' => @avatar, 'tag' => @tag
  end

end
