#!/bin/bash ../test_wrapper.sh

require_relative './app_controller_test_base'

class DashboardControllerTest < AppControllerTestBase

  def prepare
    create_kata
  end

  #- - - - - - - - - - - - - - - -

  test '62A971',
  'dashboard when no avatars' do
    prepare
    dashboard
    options = [ false, true, 'xxx' ]
    options.each do |mc|
      options.each do |ar|
        dashboard minute_columns: mc, auto_refresh: ar
      end
    end
    # How do I test @attributes in the controller object?
  end

  #- - - - - - - - - - - - - - - -

  test '62A29E',
  'dashboard when avatars with no traffic-lights' do
    prepare
    4.times { start }
    dashboard
  end

  #- - - - - - - - - - - - - - - -

  test '62AE43',
  'dashboard when avatars with some traffic lights' do
    prepare
    3.times { start; 2.times { run_tests } }
    dashboard
  end

  #- - - - - - - - - - - - - - - -

  test '62A6CB',
  'heartbeat when no avatars' do
    prepare
    heartbeat
  end

  #- - - - - - - - - - - - - - - -

  test '62A1FB',
  'heartbeat when avatars with no traffic-lights' do
    prepare
    start
    heartbeat
  end

  #- - - - - - - - - - - - - - - -

  test '62A785',
  'heartbeat when some traffic-lights' do
    prepare
    3.times { start; 2.times { run_tests } }
    heartbeat
  end

  #- - - - - - - - - - - - - - - -

  test '62A330',
  'progress when no avatars' do
    prepare
    progress
  end

  #- - - - - - - - - - - - - - - -

  test '62A619',
  'progress when avatars with no traffic-lights' do
    prepare
    start # 0
    progress
  end

  #- - - - - - - - - - - - - - - -

  test '62A4FE',
  'progress when avatar has only amber traffic-lights' do
    prepare
    start # 0
    runner.stub_run_colour(@avatar, :amber)
    run_tests
    progress
  end

  #- - - - - - - - - - - - - - - -

  private

  def dashboard(params = {})
    params[:id] = @id
    get 'dashboard/show', params
    assert_response :success
  end

  def heartbeat
    params = { :format => :js, :id => @id }
    get 'dashboard/heartbeat', params
    assert_response :success
  end

  def progress
    params = { :format => :js, :id => @id }
    get 'dashboard/progress', params
    assert_response :success
  end

end
