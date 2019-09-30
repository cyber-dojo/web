require_relative 'app_controller_test_base'

class DashboardControllerTest < AppControllerTestBase

  def self.hex_prefix
    '62A'
  end

  #- - - - - - - - - - - - - - - -

  test '970', %w( Version 0: minute_column/auto_refresh true/false ) do
    manifest = starter_manifest('Java, JUnit')
    @version = manifest['version'] = 0
    group = groups.new_group(manifest)
    @gid = group.id
    options = [ false, true, 'xxx' ]
    options.each do |mc|
      options.each do |ar|
        dashboard minute_columns: mc, auto_refresh: ar
      end
    end
  end

  test '971', %w( Version 1: minute_column/auto_refresh true/false ) do
    manifest = starter_manifest('Java, JUnit')
    @version = manifest['version'] = 1
    group = groups.new_group(manifest)
    @gid = group.id
    options = [ false, true, 'xxx' ]
    options.each do |mc|
      options.each do |ar|
        dashboard minute_columns: mc, auto_refresh: ar
      end
    end
  end

  #- - - - - - - - - - - - - - - -

  test '972', %w( version 0 dashboard ) do
    set_saver_class('SaverService')
    @version = 0
    @gid = 'chy6BJ'
    dashboard
  end

  #- - - - - - - - - - - - - - - -

  test '973', %w(
  with and without avatars, and
  with and without traffic lights ) do
    set_runner_class('RunnerService')
    set_ragger_class('RaggerService')
    manifest = starter_manifest('Python, unittest')
    @version = manifest['version'] = 1
    group = groups.new_group(manifest)
    @gid = group.id
    # an animal with a non-amber traffic-light
    1.times {
      kata = assert_join(@gid)
      @id = kata.id
      @files = kata.files.map{|filename,file| [filename,file['content']]}.to_h
      @index = 0
      post_run_tests
      assert_equal :red, kata.lights[-1].colour
    }
    # an animal with only amber traffic-lights
    1.times {
      kata = assert_join(@gid)
      @id = kata.id
      @files = kata.files.map{|filename,file| [filename,file['content']]}.to_h
      @index = 0
      change_file('hiker.py', 'syntax-error')
      post_run_tests
      assert_equal :amber, kata.lights[-1].colour
    }
    count_before = saver.log.size
    dashboard
    count_after = saver.log.size
    assert_equal 3, (count_after-count_before), [count_before,count_after]   # v1
    #tail = saver.log[-3..-1]
    #puts "tail:#{tail.inspect}"
    heartbeat
    progress
  end

  private # = = = = = = = = = = = = = =

  def dashboard(params = {})
    params[:id] ||= @gid
    params[:version] ||= @version
    get '/dashboard/show', params:params, as: :html
    assert_response :success
  end

  def heartbeat
    params = { id:@gid, version:@version }
    get '/dashboard/heartbeat', params:params, as: :json
  end

  def progress
    params = { id:@gid, version:@version }
    get '/dashboard/progress', params:params, as: :json
  end

end
