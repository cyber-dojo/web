require_relative 'app_controller_test_base'

class DashboardControllerTest < AppControllerTestBase

  def self.hex_prefix
    '62A'
  end

  #- - - - - - - - - - - - - - - -

  test '971', %w( minute_column/auto_refresh true/false ) do
    @gid = 'FxWwrr'
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
    manifest = make_manifest({ 'display_name' => 'Java, JUnit' })
    group = groups.new_group(manifest)
    @gid = group.id
    # no avatars
    dashboard
    heartbeat
    progress
    # some avatars
    3.times {
      in_kata {
        # no traffic-lights
        dashboard
        heartbeat
        progress
        # some traffic-lights
        2.times {
          post_run_tests
        }
      }
    }
    dashboard
    heartbeat
    progress
  end

  private # = = = = = = = = = = = = = =

  def dashboard(params = {})
    params[:id] = @gid
    get '/dashboard/show', params:params
    assert_response :success
  end

  def heartbeat
    params = { :format => :js, :id => @gid }
    get '/dashboard/heartbeat', params:params
    assert_response :success
  end

  def progress
    params = { :format => :js, :id => @gid }
    get '/dashboard/progress', params:params
    assert_response :success
  end

end
