require_relative 'app_controller_test_base'

class DashboardControllerTest < AppControllerTestBase

  def self.hex_prefix
    '62A'
  end

  #- - - - - - - - - - - - - - - -

  test '971', %w( minute_column/auto_refresh true/false ) do
    manifest = make_manifest({ 'display_name' => 'Java, JUnit' })
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

  test '972', %w(
  with and without avatars, and
  with and without traffic lights ) do
    set_runner_class('RunnerService')
    manifest = make_manifest({ 'display_name' => 'Python, unittest' })
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
    dashboard
    heartbeat
    progress
  end

  private # = = = = = = = = = = = = = =

  def dashboard(params = {})
    params[:id] = @gid
    get '/dashboard/show', params:params, as: :html
    assert_response :success
  end

  def heartbeat
    params = { id:@gid }
    get '/dashboard/heartbeat', params:params, as: :json
  end

  def progress
    params = { id:@gid }
    get '/dashboard/progress', params:params, as: :json
  end

end
