#!/bin/bash ../test_wrapper.sh

require_relative './app_controller_test_base'

class DownloadControllerTest < AppControllerTestBase

  def prepare
    @id = create_kata
    kata = katas[@id]
    @tar_dir = '/tmp/cyber-dojo/downloads/'
    `mkdir -p #{@tar_dir}`
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  test 'C440EF',
  'download with empty id raises' do
    prepare
    assert_raises(StandardError) { get 'downloader/download', :id => '' }
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  test 'C44849',
  'download with bad id raises' do
    prepare
    assert_raises(StandardError) { get 'downloader/download', :id => 'XX'+@id }
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  test 'C44561',
  'download of empty dojo with no avatars untars to same as original folder' do
    prepare
    get 'downloader/download', :id => @id
    assert_downloaded
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  test 'C441B1',
  'download of dojo with one avatar and one traffic-light untars to same as original folder' do
    prepare
    start
    kata_edit
    change_file('hiker.rb', 'def...')
    run_tests
    get 'downloader/download', :id => @id
    assert_downloaded
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  test 'C44E9B',
  'download of dojo with five animals and five traffic-lights untars to same as original folder' do
    prepare
    5.times do
      start
      kata_edit
      change_file('hiker.rb', 'def...')
      run_tests
      change_file('test_hiker.rb', 'def...')
      run_tests
    end
    get 'downloader/download', :id => @id
    assert_downloaded
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  def assert_downloaded
    assert_response :success
    tarfile_name = @tar_dir + "/#{@id}.tgz"
    assert File.exists?(tarfile_name), "File.exists?(#{tarfile_name})"
    untar_folder = @tar_dir + '/untar/'
    `mkdir -p #{untar_folder}`
    `cd #{untar_folder} && cat #{tarfile_name} | tar xfz -`
    src_folder = "#{storer.path}/#{outer(@id)}/#{inner(@id)}"
    dst_folder = "#{untar_folder}/#{outer(@id)}/#{inner(@id)}"
    result = `diff -r -q #{src_folder} #{dst_folder}`
    exit_status = $?.exitstatus
    assert_equal 0, exit_status
    assert_equal '', result, @id

    # new format dir exists for each avatar
    kata_path = "/tmp/cyber-dojo/new-downloads/#{outer(@id)}/#{inner(@id)}"
    kata_dir = disk[kata_path]
    assert kata_dir.exists?
    assert kata_dir.exists?('manifest.json')
    assert_equal storer.kata_manifest(@id), kata_dir.read_json('manifest.json')

    katas[@id].avatars.each do |avatar|
      avatar_path = "#{kata_path}/#{avatar.name}"
      avatar_dir = disk[kata_path]
      assert avatar_dir.exists?
    end



  end

  private

  include IdSplitter

end
